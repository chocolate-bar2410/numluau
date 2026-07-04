local module = {}

module.merge = function(... : {})
    local Result = {}

    for _,tab in {...} do
        for i,v in tab do
            Result[i] = v
        end
    end

    return Result
end

module.equals = function<T>(A : {T},B : {T})
    if #A ~= #B then return false end

    for i = 1,#A do
        if A[i] ~= B[i] then return false end
    end

    return true
end

module.fillup = function<T>(tab : {T},fill_value : T, size : number)
    local count = size - #tab
    if count == 0 then return table.clone(tab) end
    local result = table.clone(tab)

    for i = 1,count do
        table.insert(result,fill_value)
    end

    return result
end


return module