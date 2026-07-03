local module = {}
local exceptions = require("@numluau/exceptions")
local types = require("../types")
local FromTable = require("./FromTable")
local ndArray_utils = require("../utility/ndarray")
local Exceptions = require("../Exceptions")

module.arange = function(start : number,stop : number?) : types.ndArray<number>
    local result = {}

    if stop == nil then
        stop = start
        start = 1
    end

    for i = start,stop :: number do table.insert(result,i) end

    return FromTable(result)
end

module.linspace = function(start : number,stop : number?,num : number?) : types.ndArray<number>
    local result = {}
    num = (num or 50)

    if stop == nil then
        stop = start
        start = 1
    end

    if num == 1 then
        return FromTable({start})
    end

    local denominator = num - 1

    for i = 0,denominator do 
        table.insert(result,start + i * ((stop - start) / denominator)) 
    end

    return FromTable(result)
end

module.ones = function(... : number) : types.ndArray<number>
    local shape = {...}
    local size = 1

    for i = 1,#shape do
        size *= shape[i]
    end

    local result = table.create(size,1)

    local Array : types.ndArray<number> = FromTable(result)
    Array.Shape = shape
    Array.Strides = ndArray_utils.ComputeStrides(shape)
    Array.ndim = #shape

    return Array
end

module.zeros = function(... : number) : types.ndArray<number>
    local shape = {...}
    local result = {}

    local size = 1

    for i = 1,#shape do
        size *= shape[i]
    end

    for i = 1,size do table.insert(result,0) end

    local Array : types.ndArray<number> = FromTable(result)
    Array.Shape = shape
    Array.Strides = ndArray_utils.ComputeStrides(shape)
    Array.ndim = #shape

    return Array
end

module.where = function<T>(Mask : types.ndArray<boolean>,Target : types.ndArray<T>,FillValue : any) : types.ndArray<T>
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
    Result = FromTable(Result)
    Result.Shape = Target.Shape
    Result.Strides = Target.Strides
    Result.ndim = Target.ndim

    return Result
end

module.reshape = function<T>(Target : types.ndArray<T>,Shape : {number}) : types.ndArray<T>

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
end

module.flatten = function<T>(Target : types.ndArray<T>) : types.ndArray<T>
    local result = Target:copy()
    result.Shape = {#Target.Buffer}
    result.Strides = {1}
    result.ndim = 1

    return result
end

module.meshgrid = function<T>(X : types.ndArray<T>,Y : types.ndArray<T>)
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

    local x_grid = FromTable(buffer_x)
    x_grid.Shape = target_shape
    x_grid.Strides = target_stride
    x_grid.ndim = 2

    local y_grid = FromTable(buffer_y)
    y_grid.Shape = target_shape
    y_grid.Strides = target_stride
    y_grid.ndim = 2

    return x_grid,y_grid
end

module.vander = function(Target : types.ndArray<number>,col_num : number)
    if Target.ndim ~= 1 then
        exceptions.FormatException("Value","vandermonde Target array must have ndim = 1")
    end
    col_num = col_num or Target.Shape[1]

    local pow,tar = module.meshgrid(
        module.arange(0,col_num - 1), 
        Target
    )

    return tar ^ pow
end

return module :: {
    arange   : <T>(start : number,stop : number?) -> types.ndArray<number>,
    linspace : <T>(start : number,stop : number?,num : number?) -> types.ndArray<number>,
    ones     : <T>(...number) -> types.ndArray<number>,
    zeros    : <T>(...number) -> types.ndArray<number>,
    where    : <T>(Mask : types.ndArray<boolean>,Target : types.ndArray<T>,FillValue : any) -> types.ndArray<T>,
    reshape  : <T>(Target : types.ndArray<T>,Shape : {number}) -> types.ndArray<T>,
    flatten  : <T>(Target : types.ndArray<T>) -> types.ndArray<T>,
    meshgrid : <T>(X : types.ndArray<T>,Y : types.ndArray<T>) -> (types.ndArray<T>,types.ndArray<T>),
    vander : <T>(Target : types.ndArray<number>,col_num : number) -> (types.ndArray<number>)
}