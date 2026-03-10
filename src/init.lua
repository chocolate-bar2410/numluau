local ndArray = require("@self/ndarray")
local ndArray_utils = require("@self/ndarray/ndarray_utils")
local ndarray = require(script.ndarray)
local ndarray_utils = require(script.ndarray.ndarray_utils)

local types = require(script.types)

export type ndArray = types.ndArray

return {
    array = ndArray,
    arange = function(start : number,stop : number?)
        local result = {}

        if stop == nil then
            stop = start
            start = 1
        end

        for i = start,stop :: number do table.insert(result,i) end

        return ndArray(result)
    end,
    linspace = function(start,stop,num)
        local result = {}
        num = (num or 50) - 1

        if stop == nil then
            stop = start
            start = 1
        end

        for i = 0,num do 
            table.insert(
            result,
            math.floor((start + (1/num) * i * (stop - start)) * 100) / 100
        ) 
        end
        table.remove(result,#result)
        table.insert(result,stop)

        return ndArray(result)

    end,
    ones = function(...)
        local shape = {...}
        local result = {}

        local size = 1

        for i = 1,#shape do
            size *= shape[i]
        end

        for i = 1,size do table.insert(result,1) end

        local Array : types.ndArray = ndarray(result)
        Array.Shape = shape
        Array.Strides = ndarray_utils.ComputeStrides(shape)
        Array.ndim = #shape

        return Array
    end,
    zeros = function(...)
        local shape = {...}
        local result = {}

        local size = 1

        for i = 1,#shape do
            size *= shape[i]
        end

        for i = 1,size do table.insert(result,0) end

        local Array : types.ndArray = ndarray(result)
        Array.Shape = shape
        Array.Strides = ndarray_utils.ComputeStrides(shape)
        Array.ndim = #shape

        return Array
    end
}