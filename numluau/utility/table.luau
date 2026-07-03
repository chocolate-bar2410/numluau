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


return module