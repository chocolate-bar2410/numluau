local module = {}
local types = require("../types")

module.suppress = false
module.precision = 8

module.edgeitems = 3
module.threshold = 100

module.linewidth = 75

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
        parts[i] = if module.suppress then string.format(`%.{module.precision}f`,v):gsub("%.?0+$","") else string.format(`%.{module.precision}g`,v)
    end

    local truncated = false
    local truncated_pos = 0

    if #parts > module.threshold then
        truncated = true
        local new_parts = {}
        for i = 1,module.edgeitems do
            table.insert(new_parts,parts[i])
        end

        table.insert(new_parts,"...")
        truncated_pos = #new_parts

        for i = #parts - module.edgeitems + 1,#parts do
            table.insert(new_parts,parts[i])
        end

        parts = new_parts
    end

    if dim == ndArray.ndim then
        local indent_length = #("array([")
        local current_line_width = 1 + indent_length
        local result = "["
        local max_item_len = 0

        for _,v in parts do
            max_item_len = math.max(#v,max_item_len)
        end

        for i,v in parts do
            if truncated and i == truncated_pos and v == "..." then
                result ..= v .. "  "
                current_line_width += 3
                continue
            end
            local padded_v = v .. string.rep(" ",max_item_len - #v)

            local gap_width = 1

            local gap = i < #parts and string.rep(" ", gap_width) or ""
            local total_width = #gap + #padded_v

            if current_line_width + total_width > module.linewidth then

                local indent = string.rep(" ",indent_length - if tonumber(v) and tonumber(v) < 0 then 1 else 0)
                
                result ..= "\n" .. indent
                current_line_width = indent_length
            end

            result ..= padded_v .. gap
            current_line_width += total_width
        end

        return result:sub(1,#result - 1) .."]"
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

function module.VerifyShape(shape : {number}) : (boolean,string)
    local result = true
    local message = ""

    for i = 1,#shape do
        local value = shape[i]
        if typeof(value) ~= "number" then
            result = false
            message = "shape parameter must be a number"
        elseif i <= 0 then 
            result = false
            message = "shape parameter must be above 0"
        elseif i % 1 ~= 0 then
            result = false
            message = "shape parameter must be an integer"
        end
    end

    return result,message
end

function module.ComputeSize(shape : {number}) : number
    local size = 1
    for i = 1,#shape do
        size *= shape[i]
    end
    
    return size
end

function module.ForEachSlice(shape : {number},stride : {number},axis : number,offset : number,callback : (base : number) -> ())
    axis = axis or 0
    local ndim = #shape
    local target_axis = ndim - axis

    local slice_size = 1
    for i = 1,ndim do
        if i == target_axis then continue end
        slice_size *= shape[i]
    end

    for lin = 0, slice_size - 1 do
        local n = lin
        local base = offset

        for dim = ndim,1,-1 do
            if dim == target_axis then continue end

            local co_ord = n % shape[dim]
            n //= shape[dim]

            base += co_ord * stride[dim]
        end

        callback(base)
    end
end

return module