local module = {}
local types = require("../types")

function module.ReverseTable(tab)
    local result = {}
    for i = #tab,1,-1 do
        table.insert(result,tab[i])
    end

    return result
end

function module.ComputeStrides(shape)
    local ndim = #shape
    local strides = {}

    local Accumulate = 1
    for i = ndim,1,-1 do
        strides[i] = Accumulate
        Accumulate *= shape[i]
    end

    return strides
end

function module.Flatten(data,buffer)
    for i,v in data do
        if typeof(v) == "table" then
            module.Flatten(v,data)
        else
            table.insert(buffer,v)
        end
    end
end

function module.GetElement(ndArray,indices)
    local Offset = ndArray.Offset
    for i = 1,#indices do
        Offset += (indices[i] - 1) * ndArray.Strides[i]
    end

    return ndArray.Buffer[Offset + 1]
end

function module.PrettyPrint(ndArray,dim,indices : {})
     if dim > ndArray.ndim then
        return tostring(module.GetElement(ndArray, indices))
    end

    local parts = {}

    for i = 1, ndArray.Shape[dim] do
        indices[dim] = i
        parts[#parts+1] = module.PrettyPrint(ndArray, dim + 1, indices)
    end

    for i,v in parts do
        if not tonumber(v) then continue end
        parts[i] = string.format("%.8g",v)
    end

    if dim == ndArray.ndim then
        return "[" .. table.concat(parts, " ") .. "]"
    else
        local inner = table.concat(parts, "\n")
        return "[\n" .. inner:gsub("^", "  "):gsub("\n", "\n  ") .. "\n]"
    end
end

function module.NewSlice(start,stop,step)

    if step < 0 then
        start,stop = stop,start
    end

    return {
        start = start,
        stop = stop,
        step = step or 1,
        __slice = true
    }
end

function module.FlatIndex(self : types.ndArray<any>,linearIndex)
    local index = linearIndex
    local offset = 0

    for axis = #self.Shape, 1, -1 do
        local dim = self.Shape[axis]
        local stride = self.Strides[axis]

        local coord = index % dim
        index = (index - coord) / dim

        offset += coord * stride
    end

    return offset
end

function module.IdentityBuffer(rows : number, cols : number)

    cols = cols or rows

    local size = rows * cols

    local data = table.create(size,0)

    local min_dimension = math.min(rows,cols)

    for i = 1,min_dimension do
        local index = (i - 1) * cols + i
        data[index] = 1
    end

    return data
end

return module