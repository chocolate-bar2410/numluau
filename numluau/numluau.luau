local ndArray = require("./ndarray/FromTable")
local ndArray_utils = require("./ndarray/ndarray_utils")
local math_utils = require("./math/math_utils")
local aggregations = require("./math/aggregations")
local Exceptions = require("./Exceptions")

local comparison = require("./logical/comparison")
local logical = require("./logical/logical")
local lin_algebra = require("./math/lin_algebra")
--[[
to do:
    - standalone luau
        > convert require paths to relative paths
    - linear algebra
        > matrix multiplication
        > determinant
        > dot/cross product
        > transpose
        > eigen values
        > solve systems of equations
         
    - polynomial
    - calculus
        > gradient (derivative)
        > cummulative sum (integral)
    - random
    
reference:
    - https://www.youtube.com/watch?v=VXU4LSAQDSc
    - https://www.youtube.com/watch?v=DcfYgePyedM
]]

local types = require("./types")

export type ndArray<T> = types.ndArray<T>

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

        local Array : types.ndArray<any> = ndArray(result)
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

        local Array : types.ndArray<any> = ndArray(result)
        Array.Shape = shape
        Array.Strides = ndArray_utils.ComputeStrides(shape)
        Array.ndim = #shape

        return Array
    end,
    where = function(Mask : types.ndArray<any>,Target : types.ndArray<any>,FillValue : any)
        if FillValue == nil then
            Exceptions.FormatException("Array", "Fill Value must not be nil")
            return
        end

        if #Mask.Buffer ~= #Target.Buffer then
            Exceptions.FormatException("Array", "Mask array and Target array must be the same size")
            return
        end

        local Result = {}
        for i = 1,#Target.Buffer do
            Result[#Result + 1] = Mask.Buffer[i] == false and FillValue or Target.Buffer[i]
        end
        Result = ndArray(Result)
        Result.Shape = Target.Shape
        Result.Strides = Target.Strides
        Result.ndim = Target.ndim

        return Result
    end,
    reshape = function(Target : types.ndArray<any>,Shape : {number})

        local Size = 1
        for i = 1,#Shape do
            Size *= Shape[i]
        end

        if #Target.Buffer ~= Size then
            Exceptions.FormatException("Array",`Cannot reshape an array size {#Target.Buffer} into shape ({table.concat(Shape,",")})`)
        end

        local result = Target:copy()
        result.Shape = Shape
        result.Strides = ndArray_utils.ComputeStrides(Shape)
        result.ndim = #Shape

        return result
    end,
    flatten = function(Target)
        local result = Target:copy()
        result.Shape = {#Target.Buffer}
        result.Strides = {1}
        result.ndim = 1

        return result
    end
}

type out = typeof(Base) --& typeof(math_utils) & typeof(aggregations) & typeof(comparison) & typeof(logical) & typeof(lin_algebra)

return Merge(Base,math_utils,aggregations,comparison,logical,lin_algebra) :: out