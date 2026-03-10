local ndArray = require("@self/ndarray")
local ndarray = require(script.ndarray)

local types = require(script.types)

export type ndArray = types.ndArray

return {
    array = ndArray,
    arange = function(min : number,max : number?)
        local result = {}

        if max == nil then
            max = min
            min = 1
        end

        for i = min,max :: number do table.insert(result,i) end

        return ndarray(result)
    end
}