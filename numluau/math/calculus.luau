local module = {}
local types = require("../types")

local utils = require("../ndarray/ndarray_utils")
local ndArray = require("../ndarray/ndarray")

local exceptions = require("../Exceptions")

local function ApplyAcrossAxis<T>(array : types.ndArray<T>,axis : number,callback : (T,T) -> T)
    axis = array.ndim - axis
    local axis_size = array.Shape[axis]
    local axis_stride = array.Strides[axis]
    
    -- Output matches input shape
    local data = table.create(#array.Buffer, 0)
    local index = table.create(array.ndim, 0)
    local Offset = 0

    while true do
        local TrackOffsets = table.create(axis_size)
        local AxisOffset = Offset
        for a = 1, axis_size do
            TrackOffsets[a] = AxisOffset + 1
            AxisOffset += axis_stride
        end

        callback(TrackOffsets,data)

        local dim = array.ndim
        while dim >= 1 do
            if dim ~= axis then
                index[dim] += 1
                Offset += array.Strides[dim]

                if index[dim] < array.Shape[dim] then break end

                index[dim] = 0
                Offset -= array.Shape[dim] * array.Strides[dim]
            end
            dim -= 1
        end

        if dim < 1 then break end
    end 

    return ndArray(data, table.clone(array.Shape), table.clone(array.Strides), 0, array.dtype)
end

module.diff = function<T>(array : types.ndArray<T>,axis : number)
    axis = axis or 0
    local target_axis = array.ndim - axis

    local axis_size = array.Shape[target_axis]
    if axis_size <= 1 then
        exceptions.FormatException("Array", "Cannot take diff along an axis of size <= 1")
    end

    local OutputShape = table.clone(array.Shape)
    OutputShape[target_axis] -= 1
    local output_strides = utils.ComputeStrides(OutputShape)
    
    local data = {}
    local index = table.create(array.ndim, 0)
    local out_index = 1
    local offset = 0

    local axis_stride = array.Strides[target_axis]

    while true do
        local axis_offset = offset

        for _ = 1,axis_size - 1 do
            local current_index = axis_offset + 1
            local next_index = current_index + axis_stride

            data[out_index] = array.Buffer[next_index] - array.Buffer[current_index]
            out_index += 1
            axis_offset += axis_stride
        end

        local dim = array.ndim
        while dim >= 1 do
            
            if dim == target_axis then 
                dim -= 1
                continue 
            end

            index[dim] += 1
            offset += array.Strides[dim]

            if index[dim] > array.Shape[dim] then break end

            index[dim] = 0
            offset -= array.Shape[dim] * array.Strides[dim]

            dim -= 1 
        end

        if dim < 1 then break end
    end

    return ndArray(data, OutputShape, output_strides, 0, array.dtype)
end

module.gradient = function<T>(array : types.ndArray<T>,axis : number)
    axis = axis or 0

    return ApplyAcrossAxis(array, axis, function(track_offsets, output_buffer)
        local n = #track_offsets
        if n == 1 then
            output_buffer[track_offsets[1]] = 0
            return
        end
        output_buffer[track_offsets[1]] = array.Buffer[track_offsets[2]] - array.Buffer[track_offsets[1]]
        for i = 2, n - 1 do
            local prevVal = array.Buffer[track_offsets[i - 1]]
            local nextVal = array.Buffer[track_offsets[i + 1]]
            output_buffer[track_offsets[i]] = (nextVal - prevVal) / 2
        end

        output_buffer[track_offsets[n]] = output_buffer[track_offsets[n]] - output_buffer[track_offsets[n - 1]]

    end)
end

module.cumsum = function<T>(array : types.ndArray<T>,axis : number)
    axis = axis or 0

    return ApplyAcrossAxis(array, axis, function(track_offsets, output_buffer)
        local total = 0
        for i = 1,#track_offsets do
            local index = track_offsets[i]
            total += array.Buffer[index]

            output_buffer[index] = total
        end
    end)
end

module.cumprod = function<T>(array : types.ndArray<T>,axis : number)
    axis = axis or 0

    return ApplyAcrossAxis(array, axis, function(track_offsets, output_buffer)
        local total = 1
        for i = 1,#track_offsets do
            local index = track_offsets[i]
            total *= array.Buffer[index]

            output_buffer[index] = total
        end
    end)
end

export type interface = {
    diff : (array : types.ndArray<any>,axis : number) -> types.ndArray<any>,
    gradient : (array : types.ndArray<any>,axis : number) -> types.ndArray<any>,
    cumsum : (array : types.ndArray<any>,axis : number) -> types.ndArray<any>,
    cumprod : (array : types.ndArray<any>,axis : number) -> types.ndArray<any>,
}

return module :: interface