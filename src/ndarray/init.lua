local schema = {}
local meta = {}

--[[
to do:
    - negative index column slicing
    - multidimensional slicing

reference:
    - https://www.youtube.com/watch?v=VXU4LSAQDSc
]]

local ndarray_utils = require(script.ndarray_utils)

type ndArray = {
    ndim : number,
    Offset : number,
    Buffer : {},
    Shape : {number},
    Strides : {number},
} & typeof(schema)



local function ProcessArray(array : {},prevndim : number?,prevshape : {}?)
    local ndim = prevndim or 0
    local isvalid = true
    local shape = prevshape or {#array}

    if typeof(array) ~= "table" then return true,0,{} end

    local SameSize = true
    local Size = nil 
    local Recursive = false

    for i, v in array do
        Recursive = Recursive or typeof(v) == "table"

        if not Size then 
            Size = Recursive and #v or 0
            continue 
        end

        if not Recursive then continue end

        SameSize = #v == Size
    end
 
    if not Recursive then return true,1,{#array} end

    if not SameSize then 
        error("Malformed array: Array elements must be the same size")
        return false 
    end

    local SameDimension = true
    local Dimension = nil

    for i, v in array do
        local Valid,Newndim = ProcessArray(v,ndim,shape)

        isvalid = isvalid and Valid

        if not Dimension then 
            Dimension = Newndim
            continue 
        end

        SameDimension = Newndim == Dimension
    end

    ndim = Dimension + 1
   
    shape[ndim] = Size

    if not SameDimension then 
        error("Malformed array: Array elements must have the same dimensionality")
        return false
    end

    return isvalid,ndim,shape
end

local function New_ndarray(data,Shape,Strides,Offset)
    return setmetatable({
        Buffer = data,
        ndim = #Shape,
        Shape = Shape,
        Strides = Strides,
        Offset = Offset,
    },meta)
end

local function index_ndarray(ndArray : ndArray,index : number)
    if index < 0 then
        index = ndArray.Shape[1] + index + 1
    end

    if index < 0 or index > ndArray.Shape[1] then
        return
    end

    local NewOffset = ndArray.Offset + (index-1) * ndArray.Strides[1]

    local NewShape = table.move(ndArray.Shape, 2, #ndArray.Shape, 1,{})
    local NewStrides = table.move(ndArray.Strides, 2, #ndArray.Shape, 1,{})

    if #NewShape == 0 then
        return ndArray.Buffer[NewOffset + 1]
    end

    return New_ndarray(ndArray.Buffer,NewShape,NewStrides,NewOffset)
end

local function set_ndarray(ndArray : ndArray,index : number,value : any)
    if index < 1 or index > ndArray.Shape[1] then
        return
    end

    local NewOffset = ndArray.Offset + (index-1) * ndArray.Strides[1]

    local NewShape = table.move(ndArray.Shape, 2, #ndArray.Shape, 1,{})
    local NewStrides = table.move(ndArray.Strides, 2, #ndArray.Shape, 1,{})

    if #NewShape == 0 then
        ndArray.Buffer[NewOffset + 1] = value
        return value
    end

    return New_ndarray(ndArray.Buffer,NewShape,NewStrides,NewOffset)
end

local Slice = function(self : ndArray, Keys : {})
    local NewShape = {}
    local NewStrides = {}
    local NewOffset = self.Offset

    local axis = 1

    for _, key in ipairs(Keys) do
        local stride = self.Strides[axis]

        if key == 0 then
            -- full slice
            NewShape[#NewShape+1] = self.Shape[axis]
            NewStrides[#NewStrides+1] = stride
            axis += 1
        elseif type(key) == "number" then
            -- integer index removes axis
            NewOffset += (key - 1) * stride
            axis += 1

        elseif type(key) == "table" and key.__slice then
            -- slice keeps axis
            local start = key.start or 1
            local stop = key.stop or self.Shape[axis]
            local step = key.step or 1

            if start < 0 then start += self.Shape[axis] + 1 end
            if stop < 0 then stop += self.Shape[axis] + 1 end

            NewOffset += (start - 1) * stride
            local newSize = math.floor((stop - start) / step) + 1

            NewShape[#NewShape+1] = newSize
            NewStrides[#NewStrides+1] = stride * step

            axis += 1
        end
    end

    -- append remaining axes
    for i = axis, self.ndim do
        NewShape[#NewShape+1] = self.Shape[i]
        NewStrides[#NewStrides+1] = self.Strides[i]
    end

    if #NewShape == 0 then
        return self.Buffer[NewOffset + 1]
    end

    return New_ndarray(self.Buffer, NewShape, NewStrides, NewOffset)
end


local GetElement = function(self : ndArray,indices)
    local Offset = self.Offset
    for i = 1,#indices do
        Offset += (indices[i] - 1) * self.Strides[i]
    end

    return self.Buffer[Offset + 1]
end

local function PrettyPrint(self : ndArray,ndim,indices : {})
     if ndim > self.ndim then
        return tostring(GetElement(self, indices))
    end

    local parts = {}

    for i = 1, self.Shape[ndim] do
        indices[ndim] = i
        parts[#parts+1] = PrettyPrint(self, ndim + 1, indices)
    end

    if ndim == self.ndim then
        return table.concat(parts, " ")
    else
        local inner = table.concat(parts, "\n")
        return "[\n" .. inner:gsub("^", "  "):gsub("\n", "\n  ") .. "\n]"
    end
end

meta.__index = function(self : ndArray,index)
    if typeof(index) == "number" then
        return index_ndarray(self, index)
    end
    
    if typeof(index) == "table" then
        return Slice(self,index)
    end

    return rawget(self, index) or schema[index]
end

meta.__newindex = function(self : ndArray,index,value)
    if typeof(index) == "number" then
        return set_ndarray(self, index,value)
    end

    return rawset(self, index,value)
end

meta.__tostring = function(self : ndArray)
    if self.ndim == 0 then
        return tostring(self.Buffer[self.Offset + 1])
    end

    return PrettyPrint(self, 1, {})
end

schema.copy = function(self : ndArray)
    local Data = table.clone(self.Buffer)

    return New_ndarray(Data, self.Shape, self.Strides, self.Offset)
end

schema.view = function(self : ndArray)
    return New_ndarray(self.Buffer, self.Shape, self.Strides, self.Offset)
end

return function(data : {})
    local valid,_,shape = ProcessArray(data)

    if valid ~= true then return end
    local Buffer = {}
    ndarray_utils.ReverseTable(shape)
    ndarray_utils.Flatten(data, Buffer)

    return New_ndarray(Buffer,shape,ndarray_utils.ComputeStrides(shape),0) :: ndArray
end