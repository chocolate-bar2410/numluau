local module = {}

function module.ReverseTable(tab)
    local i,j = 1,#tab
    while i > j do
        tab[i], tab[j] = tab[j],tab[i]
        i += 1
        j -= 1
    end

    return tab
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

function module.PrettyPrint(ndArray,ndim,indices : {})
     if ndim > ndArray.ndim then
        return tostring(module.GetElement(ndArray, indices))
    end

    local parts = {}

    for i = 1, ndArray.Shape[ndim] do
        indices[ndim] = i
        parts[#parts+1] = module.PrettyPrint(ndArray, ndim + 1, indices)
    end

    if ndim == ndArray.ndim then
        return table.concat(parts, " ")
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

return module