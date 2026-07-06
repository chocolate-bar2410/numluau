local module = {}
local types = require("../types")

local utils = require("../utility/ndarray")

local exceptions = require("../Exceptions")

module.diff = function<T>(array : types.ndArray<T>,axis : number)
    axis = axis or 0

    local target_axis = array.ndim - axis
    local target_shape = array.Shape[target_axis]
    local target_stride = array.Strides[target_axis]

    local result = array:copy()

    utils.ForEachSlice(array.Shape, array.Strides, axis, array.Offset, function(base: number)

        local base_index = base
        for i = 1, target_shape - 1 do
            local indexA = base_index + 1
            local indexB = base_index + target_stride + 1

            result.Buffer[indexA] = array.Buffer[indexB] - array.Buffer[indexA]

            base_index += target_stride
        end
    end)
    result.Shape[target_axis] -= 1

    return result
end

module.gradient = function<T>(array : types.ndArray<T>,spacing : types.ndArray<T> | types.ndArray<T> | number,axis : number)
    if axis == nil then
        local result = {}
        for i = array.ndim - 1, 0,-1 do
            table.insert(result,module.gradient(array,spacing, i))
        end

        return unpack(result)
    end

    local target_axis = array.ndim - axis
    local target_shape = array.Shape[target_axis]
    local target_stride = array.Strides[target_axis]

    local result = array:copy()

    utils.ForEachSlice(array.Shape, array.Strides, axis, array.Offset, function(base: number)
        for i = 0, target_shape - 1 do
            local current = base + (i * target_stride) + 1
            local prev_index = base + ((i - 1) * target_stride) + 1
            local next_index = base + ((i + 1) * target_stride) + 1

            local has_prev = i > 0
            local has_next = i < target_shape - 1

            local rise = 0
            local run = 1

            if has_next and has_prev then
                if typeof(spacing) == "number" then
                    run = spacing * 2
                elseif utils.is_ndarray(spacing) then
                    run = spacing.Buffer[prev_index] - spacing.Buffer[next_index]
                end

                rise = array.Buffer[prev_index] - array.Buffer[next_index]
            elseif has_next then
                if typeof(spacing) == "number" then
                    run = spacing
                elseif utils.is_ndarray(spacing) then
                    run = spacing.Buffer[current] - spacing.Buffer[next_index]
                end

                rise = array.Buffer[current] - array.Buffer[next_index]
            else
                if typeof(spacing) == "number" then
                    run = spacing
                elseif utils.is_ndarray(spacing) then
                    run = spacing.Buffer[prev_index] - spacing.Buffer[current]
                end

                rise = array.Buffer[prev_index] - array.Buffer[current]
            end


            result.Buffer[current] = rise/run
        end
    end)

    return result
end

module.cumsum = function<T>(array : types.ndArray<T>,axis : number)
    axis = axis or 0

    local target_axis = array.ndim - axis
    local target_shape = array.Shape[target_axis]
    local target_stride = array.Strides[target_axis]

    local result = array:copy()

    utils.ForEachSlice(array.Shape, array.Strides, axis, array.Offset, function(base: number)
        local sum = 0
        local base_index = base
        for i = 1, target_shape do
            sum += array.Buffer[base_index + 1]
            result.Buffer[base_index + 1] = sum

            base_index += target_stride
        end
    end)

    return result
end

module.cumprod = function<T>(array : types.ndArray<T>,axis : number)
    axis = axis or 0

    local target_axis = array.ndim - axis
    local target_shape = array.Shape[target_axis]
    local target_stride = array.Strides[target_axis]

    local result = array:copy()

    utils.ForEachSlice(array.Shape, array.Strides, axis, array.Offset, function(base: number)
        local product = 1
        local base_index = base
        for i = 1, target_shape do
            print(base_index + 1)
            product *= array.Buffer[base_index + 1]
            result.Buffer[base_index + 1] = product

            base_index += target_stride
        end
    end)

    return result
end

export type interface = {
    diff : (array : types.ndArray<any>,axis : number) -> types.ndArray<any>,
    gradient : (array : types.ndArray<any>,axis : number) -> types.ndArray<any>,
    cumsum : (array : types.ndArray<any>,axis : number) -> types.ndArray<any>,
    cumprod : (array : types.ndArray<any>,axis : number) -> types.ndArray<any>,
}

return module :: interface