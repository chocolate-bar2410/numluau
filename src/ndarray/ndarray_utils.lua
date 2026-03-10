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

return module