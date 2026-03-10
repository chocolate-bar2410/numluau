local schema = {}
local meta = {}

--[[
to do:
    - broadcasting

reference:
    - https://www.youtube.com/watch?v=VXU4LSAQDSc
]]

local Package = script.Parent
local utils = require(script.ndarray_utils)
local types = require(Package.types)

local Broadcast = require(script.Broadcast)

local function ProcessArray(array : {},prevndim : number?,prevshape : {}?)
    local ndim = prevndim or 0
    local isvalid = true

    if typeof(array) ~= "table" then return true,0,{},typeof(array) end

    local shape = prevshape or {#array}

    local SameSize = true
    local Size = nil 
    local dtype = nil

    for i, v in array do
        dtype = typeof(v)

        if not Size then 
            Size = dtype == "table" and #v or 0
            continue 
        end

        if dtype ~= "table" then continue end

        SameSize = #v == Size
    end
 
    if dtype ~= "table" then return true,1,{#array},dtype end

    if not SameSize then 
        error("Malformed array: Array elements must be the same size")
        return false 
    end

    local SameDimension = true
    local Dimension = nil

    for i, v in array do
        local Valid,Newndim,_,innerdtype = ProcessArray(v,ndim,shape)

        isvalid = isvalid and Valid

        if not Dimension then 
            Dimension = Newndim
            continue 
        end

        dtype = innerdtype

        SameDimension = Newndim == Dimension
    end

    ndim = Dimension + 1
   
    shape[ndim] = Size

    if not SameDimension then 
        error("Malformed array: Array elements must have the same dimensionality")
        return false
    end

    return isvalid,ndim,shape,dtype
end

local function New_ndarray(data,Shape,Strides,Offset,dtype : string)
    return setmetatable({
        Buffer = data,
        ndim = #Shape,
        Shape = Shape,
        Strides = Strides,
        Offset = Offset,
        type = "ndArray",
        dtype = dtype
    },meta)
end

local function index_ndarray(ndArray : types.ndArray,index : number)
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

    return New_ndarray(ndArray.Buffer,NewShape,NewStrides,NewOffset,ndArray.dtype)
end

local function set_ndarray(ndArray : types.ndArray,index : number,value : any)
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

    return New_ndarray(ndArray.Buffer,NewShape,NewStrides,NewOffset,ndArray.dtype)
end

local Slice = function(self : types.ndArray, Keys : {})
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

    return New_ndarray(self.Buffer, NewShape, NewStrides, NewOffset,self.dtype)
end

meta.__index = function(self : types.ndArray,index)
    if typeof(index) == "number" then
        return index_ndarray(self, index)
    end

    if typeof(index) == "string" and index:sub(1,1):match("[^%a]") then
        local Slices = {}

        for section in index:gmatch("[^,]+") do
            section = section:gsub("%s+","")
            local start,stop,step = section:match("([^:]*):([^:]*):?([^:]*)")

            if start then
                start = tonumber(start)
                stop = tonumber(stop)
                step = tonumber(step) or 1

                table.insert(Slices,utils.NewSlice(start, stop, step))
            else
                table.insert(Slices,tonumber(section))
            end

        end
        return Slice(self, Slices)
    end

    return rawget(self, index) or schema[index]
end

meta.__newindex = function(self : types.ndArray,index,value)
    if typeof(index) == "number" then
        return set_ndarray(self, index,value)
    end

    return rawset(self, index,value)
end

meta.__tostring = function(self : types.ndArray)
    if self.ndim == 0 then
        return tostring(self.Buffer[self.Offset + 1])
    end

    return utils.PrettyPrint(self, 1, {})
end

meta.__add = function(self : types.ndArray,value)
    if typeof(value) ~= "table" then
        local Result = self:copy()
        for i = 1,#Result.Buffer do
            Result.Buffer[i] += value
        end

        return Result
    end

    if not value.type or value.type ~= "ndArray" then return end
    if value.ndim == 0 then return self + value.Buffer[1] end

    local Result,OutShape = Broadcast.CreateBroadcastArray(self,value,function(a,b) return a + b end)

    Result = New_ndarray(Result,OutShape,utils.ComputeStrides(OutShape),0,self.dtype)

    return Result
end

meta.__sub = function(self : types.ndArray,value)
    if typeof(value) ~= "table" then
        local Result = self:copy()
        for i = 1,#Result.Buffer do
            Result.Buffer[i] -= value
        end

        return Result
    end

    if not value.type or value.type ~= "ndArray" then return end
    if value.ndim == 0 then return self - value.Buffer[1] end

    local Result,OutShape = Broadcast.CreateBroadcastArray(self,value,function(a,b) return a - b end)

    Result = New_ndarray(Result,OutShape,utils.ComputeStrides(OutShape),0,self.dtype)

    return Result
end

meta.__mul = function(self : types.ndArray,value)
    if typeof(value) ~= "table" then
        local Result = self:copy()
        for i = 1,#Result.Buffer do
            Result.Buffer[i] *= value
        end

        return Result
    end

    if not value.type or value.type ~= "ndArray" then return end
    if value.ndim == 0 then return self * value.Buffer[1] end

    local Result,OutShape = Broadcast.CreateBroadcastArray(self,value,function(a,b) return a * b end)

    Result = New_ndarray(Result,OutShape,utils.ComputeStrides(OutShape),0,self.dtype)

    return Result
end

meta.__div = function(self : types.ndArray,value)
    if typeof(value) ~= "table" then
        local Result = self:copy()
        for i = 1,#Result.Buffer do
            Result.Buffer[i] /= value
        end

        return Result
    end

    if not value.type or value.type ~= "ndArray" then return end
    if value.ndim == 0 then return self / value.Buffer[1] end

    local Result,OutShape = Broadcast.CreateBroadcastArray(self,value,function(a,b) return a / b end)

    Result = New_ndarray(Result,OutShape,utils.ComputeStrides(OutShape),0,self.dtype)

    return Result
end

meta.__idiv = function(self : types.ndArray,value)
    if typeof(value) ~= "table" then
        local Result = self:copy()
        for i = 1,#Result.Buffer do
            Result.Buffer[i] //= value
        end

        return Result
    end

    if not value.type or value.type ~= "ndArray" then return end
    if value.ndim == 0 then return self // value.Buffer[1] end

    local Result,OutShape = Broadcast.CreateBroadcastArray(self,value,function(a,b) return a // b end)

    Result = New_ndarray(Result,OutShape,utils.ComputeStrides(OutShape),0,self.dtype)

    return Result
end

meta.__pow = function(self : types.ndArray,value)
    if typeof(value) ~= "table" then
        local Result = self:copy()
        for i = 1,#Result.Buffer do
            Result.Buffer[i] ^= value
        end

        return Result
    end

    if not value.type or value.type ~= "ndArray" then return end
    if value.ndim == 0 then return self ^ value.Buffer[1] end

    local Result,OutShape = Broadcast.CreateBroadcastArray(self,value,function(a,b) return a ^ b end)

    Result = New_ndarray(Result,OutShape,utils.ComputeStrides(OutShape),0,self.dtype)

    return Result
end

meta.__mod = function(self : types.ndArray,value)
    if typeof(value) ~= "table" then
        local Result = self:copy()
        for i = 1,#Result.Buffer do
            Result.Buffer[i] %= value
        end

        return Result
    end

    if not value.type or value.type ~= "ndArray" then return end
    if value.ndim == 0 then return self % value.Buffer[1] end

    local Result,OutShape = Broadcast.CreateBroadcastArray(self,value,function(a,b) return a % b end)

    Result = New_ndarray(Result,OutShape,utils.ComputeStrides(OutShape),0,self.dtype)

    return Result
end

schema.copy = function(self : types.ndArray)
    local Data = table.clone(self.Buffer)

    return New_ndarray(Data, self.Shape, self.Strides, self.Offset,self.dtype)
end

schema.view = function(self : types.ndArray)
    return New_ndarray(self.Buffer, self.Shape, self.Strides, self.Offset,self.dtype)
end

return function(data : {})
    local valid,_,shape,dtype = ProcessArray(data)

    if valid ~= true then return end
    local Buffer = {}
    
    if typeof(data) == "table" then
        utils.Flatten(data, Buffer)
    else
        table.insert(Buffer,data)
    end

    return New_ndarray(Buffer,shape,utils.ComputeStrides(shape),0,dtype) :: types.ndArray
end