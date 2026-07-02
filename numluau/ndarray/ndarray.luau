local schema = {}
local meta = {}

local utils = require("../utility/ndarray")
local types = require("../types")

local Broadcast = require("./Broadcast")
local Exceptions = require("../Exceptions")

local function isValid<T>(data : {T},dtype : string) : boolean | string
    for i = 1,#data do
        if typeof(data[i]) ~= dtype then return "ndArray elements must have the same type" end
    end

    return true
end

local function New_ndarray<T>(data : {T},Shape : {number},Strides : {number},Offset : number,dtype : string)
    if typeof(data) ~= "table" then data = {data} end

    local validation = isValid(data, dtype)
    if type(validation) == "string" then Exceptions.FormatException("Malformed",validation) end

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

local function index_ndarray(ndArray : types.ndArray<any>,index : number)
    if index < 0 then
        index = ndArray.Shape[1] + index + 1
    end

    if index < 0 or index > ndArray.Shape[1] then
        Exceptions.FormatException("Array", `index {index} is out of bounds`)
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

local function set_ndarray(ndArray : types.ndArray<any>,index : number,value : any)
    if index < 1 or index > ndArray.Shape[1] then
        Exceptions.FormatException("Array", `index {index} is out of bounds`)
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

local function is_ndarray(target)
    return type(target) == "table" and target.type == "ndArray"
end

local Slice = function(self : types.ndArray<any>, Keys : {})
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

meta.__index = function(self : types.ndArray<any>,index)
    if typeof(index) == "number" then
        return index_ndarray(self, index)
    end

    if typeof(index) == "table" and index.type and index.type == "ndArray" then
        if #index.Buffer ~= #self.Buffer then
            Exceptions.FormatException("Array", "Mask array and Target array must be the same size")
            return
        end

        local result = {}

        for i = 1,#self.Buffer do
            if index.Buffer[i] == false then continue end
            result[#result + 1] = self.Buffer[i]
        end

        return New_ndarray(result, {#result}, {1}, 0, self.dtype)
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

meta.__newindex = function(self : types.ndArray<any>,index,value)
    if typeof(index) == "number" then
        return set_ndarray(self, index,value)
    end

    return rawset(self, index,value)
end

meta.__tostring = function(self : types.ndArray<any>)
    if self.ndim == 0 then
        return `array({tostring(self.Buffer[self.Offset + 1])})`
    end

    return `array({utils.PrettyPrint(self, 1, {})})`
end

meta.__add = function<T>(self : types.ndArray<T>,value)
    local Result,OutShape = Broadcast.CreateBroadcastArray(self,value,function(a,b) return a + b end)
    local dtype = if is_ndarray(self) then self.dtype else value.dtype

    Result = New_ndarray(Result,OutShape,utils.ComputeStrides(OutShape),0,dtype)
    return Result
end

meta.__sub = function<T>(self : types.ndArray<T>,value)
    local Result,OutShape = Broadcast.CreateBroadcastArray(self,value,function(a,b) return a - b end)
    local dtype = if is_ndarray(self) then self.dtype else value.dtype

    Result = New_ndarray(Result,OutShape,utils.ComputeStrides(OutShape),0,dtype)
    return Result
end

meta.__mul = function<T>(self : types.ndArray<T>,value)
    local Result,OutShape = Broadcast.CreateBroadcastArray(self,value,function(a,b) return a * b end)
    local dtype = if is_ndarray(self) then self.dtype else value.dtype

    Result = New_ndarray(Result,OutShape,utils.ComputeStrides(OutShape),0,dtype)
    return Result
end

meta.__div = function<T>(self : types.ndArray<T>,value)
    local Result,OutShape = Broadcast.CreateBroadcastArray(self,value,function(a,b) return a / b end)
    local dtype = if is_ndarray(self) then self.dtype else value.dtype

    Result = New_ndarray(Result,OutShape,utils.ComputeStrides(OutShape),0,dtype)
    return Result
end

meta.__idiv = function<T>(self : types.ndArray<T>,value)
    local Result,OutShape = Broadcast.CreateBroadcastArray(self,value,function(a,b) return a // b end)
    local dtype = if is_ndarray(self) then self.dtype else value.dtype

    Result = New_ndarray(Result,OutShape,utils.ComputeStrides(OutShape),0,dtype)
    return Result
end

meta.__pow = function<T>(self : types.ndArray<T>,value)
    local Result,OutShape = Broadcast.CreateBroadcastArray(self,value,function(a,b) return a ^ b end)
    local dtype = if is_ndarray(self) then self.dtype else value.dtype

    Result = New_ndarray(Result,OutShape,utils.ComputeStrides(OutShape),0,dtype)
    return Result
end

meta.__mod = function<T>(self : types.ndArray<T>,value)
    local Result,OutShape = Broadcast.CreateBroadcastArray(self,value,function(a,b) return a % b end)
    local dtype = if is_ndarray(self) then self.dtype else value.dtype

    Result = New_ndarray(Result,OutShape,utils.ComputeStrides(OutShape),0,dtype)
    return Result
end

meta.__unm = function<T>(self : types.ndArray<T>)
    
    local Result = self:copy()
    for i,v in self do
        Result.Buffer[i] *= -1
    end

    return Result
end

meta.__iter = function<T>(self : types.ndArray<T>)
    local size = 1
    for _,v in self.Shape do
        size *= v
    end

    if size == 0 then return function() end end

    local dimensions = table.create(self.ndim,0)

    local yielded = 0

    return function()
        if yielded >= size then return end

        local index = self.Offset
        
        for i = 1,#dimensions do
            index += dimensions[i] * self.Strides[i]
        end
        
        for i = self.ndim,1,-1 do
            dimensions[i] += 1
            if dimensions[i] < self.Shape[i] then break end

            dimensions[i] = 0
        end

        yielded += 1

        return index + 1,self.Buffer[index + 1]
    end
end

meta.__len = function<T>(self : types.ndArray<T>) : number
    local size = 1
    for i = 1,#self.Shape do
        size *= self.Shape[i]
    end

    return size
end

-- methods

schema.copy = function<T>(self : types.ndArray<T>)
    local Data = table.clone(self.Buffer)

    return New_ndarray(Data, self.Shape, self.Strides, self.Offset,self.dtype)
end

schema.view = function<T>(self : types.ndArray<T>)
    return New_ndarray(self.Buffer, self.Shape, self.Strides, self.Offset,self.dtype)
end

schema.reshape = function<T>(self : types.ndArray<T>,... : number)
    local Shape = {...}

    local Size = 1
    for i = 1,#Shape do
        Size *= Shape[i]
    end

    if #self.Buffer ~= Size then
        Exceptions.FormatException("Array",`Cannot reshape an array with size {#self.Buffer} into shape ({table.concat(Shape,",")})`)
    end

    local result = self:view()
    result.Shape = Shape
    result.Strides = utils.ComputeStrides(Shape)
    result.ndim = #Shape

    return result
end

schema.flatten = function<T>(self : types.ndArray<T>)
    local result = self:view()
    result.Shape = {#self}
    result.Strides = {1}
    result.ndim = 1

    return result
end

schema.eye = function<T>(self : types.ndArray<T>)
    if self.ndim ~= 2 then
        Exceptions.FormatException("LinAlg", ("tried to find identity from a ndarray with ndim: %d"):format(self.ndim))
        return
    end

    local rows = self.Shape[1]
    local cols = self.Shape[2]

    local data = utils.IdentityBuffer(rows, cols)
    return New_ndarray(data, {rows,cols}, {cols,1}, 0, self.dtype)
end

schema.transpose = function<T>(self : types.ndArray<T>)
    if self.ndim < 2 then
        return self
    end

    local new_shape = utils.ReverseTable(self.Shape)
    local new_strides = utils.ReverseTable(self.Strides)

    local transposed = self:view()
    transposed.Shape = new_shape
    transposed.Strides = new_strides

    return transposed
end

schema.item = function<T>(self : types.ndArray<T>,... : number)
    if self.ndim == 0 then
        return self.Buffer[1]
    end
    local args = {...}

    for i,v in args do
        args[i] = v * self.Strides[i] - 1
    end

    local index = 0
    for i,v in args do
        index += v
    end

    return self.Buffer[index]
end

schema.toflatlist = function<T>(self : types.ndArray<T>) : {T}
    local data = {}

    for _,v in self do
        table.insert(data,v)
    end

    return data
end

schema.swap = function<T>(self : types.ndArray<T>,index1 : number,index2 : number,axis : number)
    if self.ndim == 0 then return end

    if self.ndim == 1 then
        local temp = self[index1]

        self[index1] = self[index2]
        self[index2] = temp

        return
    end
    axis = axis or 0
    local target_axis = self.ndim - axis

    local delta = (index2 - index1) * self.Strides[target_axis]

    utils.ForEachSlice(self.Shape, self.Strides, axis, self.Offset, function(base)
        local a = base + (index1 - 1) * self.Strides[target_axis]
        local b = a + delta

        self.Buffer[a + 1], self.Buffer[b + 1] = self.Buffer[b + 1],self.Buffer[a + 1]
    end)

end

return New_ndarray