local ndArray = require("@self/ndarray")
local ndArray_utils = require("@self/ndarray/ndarray_utils")
local math_utils = require("@self/math/math_utils")
local aggregations = require("@self/math/aggregations")
--[[
to do:
    - math
        > aggregations
        > linear algebra
    - arrays
        > reshaping
    - logical
        > comparisons
        > logical operations
    

reference:
    - https://www.youtube.com/watch?v=VXU4LSAQDSc
]]

local types = require(script.types)

export type ndArray = types.ndArray

local Merge = function(... : {})
    local Result = {}

    for _,tab in {...} do
        for i,v in tab do
            Result[i] = v
        end
    end

    return Result
end

local Base = {
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
            math.floor(math.lerp(start,stop,(1/num) * i) * 100) / 100
        ) 
        end
        table.remove(result,#result)
        table.insert(result,stop)

        return ndArray(result)

    end,
    ones = function(...)
        local shape = {...}
        local size = 1

        for i = 1,#shape do
            size *= shape[i]
        end

        local result = table.create(size,1)

        local Array : types.ndArray = ndArray(result)
        Array.Shape = shape
        Array.Strides = ndArray_utils.ComputeStrides(shape)
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

        local Array : types.ndArray = ndArray(result)
        Array.Shape = shape
        Array.Strides = ndArray_utils.ComputeStrides(shape)
        Array.ndim = #shape

        return Array
    end,
}

type out = typeof(Base) & typeof(math_utils) & typeof(aggregations)

return Merge(Base,math_utils,aggregations) :: out