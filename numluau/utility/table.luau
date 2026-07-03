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



return module