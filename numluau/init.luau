local ndArray = require("@self/ndarray/FromTable")
local ndArray_utils = require("@self/ndarray/ndarray_utils")
local math_utils = require("@self/math/math_utils")
local aggregations = require("@self/math/aggregations")
local Exceptions = require("@self/Exceptions")

local comparison = require("@self/logical/comparison")
local logical = require("@self/logical/logical")

local calculus = require("@self/math/calculus")
--[[
to do:
    - linear algebra
        > matrix multiplication --[done]
        > determinant --[done]
        > dot/cross product --[done]
        > transpose --[done]
        > eigen values --[done]
        > solve systems of equations --[done]
    - calculus
        > gradient (derivative) --[done]
        > cummulative sum (integral) --[done]
        > cummulative product --[done]
    - polynomial --[WIP]
    - random --[incomplete]
    
reference:
    - https://www.youtube.com/watch?v=VXU4LSAQDSc
    - https://www.youtube.com/watch?v=DcfYgePyedM
]]

local types = require("@self/types")

export type ndArray<T> = types.ndArray<T>
export type Generator = types.Generator

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
    arange = function(start : number,stop : number?) : ndArray<number>
        local result = {}

        if stop == nil then
            stop = start
            start = 1
        end

        for i = start,stop :: number do table.insert(result,i) end

        return ndArray(result)
    end,
    linspace = function(start : number,stop : number?,num : number?) : ndArray<number>
        local result = {}
        num = (num or 50)

        if stop == nil then
            stop = start
            start = 1
        end

        if num == 1 then
            return ndArray({start})
        end

        local denominator = num - 1

        for i = 0,denominator do 
            table.insert(result,start + i * ((stop - start) / denominator)) 
        end

        return ndArray(result)
    end,
    ones = function(... : number) : ndArray<number>
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
    zeros = function(... : number) : ndArray<number>
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
    where = function(Mask : types.ndArray<boolean>,Target : types.ndArray<any>,FillValue : any) : types.ndArray<any>
        if FillValue == nil then
            Exceptions.FormatException("Array", "Fill Value must not be nil")
            return
        end

        if #Mask ~= #Target then
            Exceptions.FormatException("Array", "Mask array and Target array must be the same size")
            return
        end

        local Result = {}
        for i,v in Target do
            Result[#Result + 1] = Mask.Buffer[i] == false and FillValue or Target.Buffer[i]
        end
        Result = ndArray(Result)
        Result.Shape = Target.Shape
        Result.Strides = Target.Strides
        Result.ndim = Target.ndim

        return Result
    end,
    reshape = function(Target : types.ndArray<any>,Shape : {number}) : types.ndArray<any>

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
    flatten = function(Target) : types.ndArray<any>
        local result = Target:copy()
        result.Shape = {#Target.Buffer}
        result.Strides = {1}
        result.ndim = 1

        return result
    end,
    meshgrid = function<T>(X : types.ndArray<T>,Y : types.ndArray<T>)
        if X.ndim ~= 1 or Y.ndim ~= 1 then
            Exceptions.Exception("Array","meshgrid inputs must have ndim = 1")
        end
        
        local x_data = X:toflatlist()
        local y_data = Y:toflatlist()

        local nx = #x_data
        local ny = #y_data

        local buffer_x = table.create(nx * ny)
        local buffer_y = table.create(nx * ny)

        local index = 1
        for r = 1, ny do
            local y_val = y_data[r]
            for c = 1, nx do
                buffer_x[index] = x_data[c]
                buffer_y[index] = y_val
                index += 1
            end
        end

        local target_shape = {ny,nx}
        local target_stride = {nx,1}

        local x_grid = ndArray(buffer_x)
        x_grid.Shape = target_shape
        x_grid.Strides = target_stride
        x_grid.ndim = 2

        local y_grid = ndArray(buffer_y)
        y_grid.Shape = target_shape
        y_grid.Strides = target_stride
        y_grid.ndim = 2

        return x_grid,y_grid
    end,
    
    linalg = require("@self/math/lin_algebra"),
    random = require("@self/random/random"),
    version = {major = 1, minor = 1} :: types.Version
}

type out = typeof(Base) & typeof(math_utils) & typeof(aggregations) & typeof(comparison) & typeof(logical) & typeof(calculus)

return Merge(Base,math_utils,aggregations,comparison,logical,calculus) :: out