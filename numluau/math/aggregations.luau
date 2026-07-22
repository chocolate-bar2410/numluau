--!native
local module = {}
local ndArray_utils = require("../utility/ndarray")
local types = require("../types")
local ndArray = require("../ndarray/ndarray")

local function CollapseAll<T>(array: types.ndArray<any>, initValue: number, callback: (T, T) -> T)
	local Accumulator = initValue

	for i, v in array do
		Accumulator = callback(Accumulator, array.Buffer[i])
	end

	return ndArray(Accumulator, {}, {}, 0, typeof(Accumulator))
end

local function Aggregate<T>(array: types.ndArray<any>, axis: number, initValue: number, callback: (T, T, number?) -> T)
	if axis == nil then return CollapseAll(array, initValue, callback) end

	axis = array.ndim - axis
	initValue = initValue ~= nil and initValue or 0
	local axis_size = array.Shape[axis]
	local axis_stride = array.Strides[axis]

	local data = {}
	local index = table.create(array.ndim, 0)
	local out_index = 1

	local Offset = 0

	while true do
		local Acculmulator = initValue
		local AxisOffset = Offset

		for a = 0, axis_size - 1 do
			Acculmulator = callback(Acculmulator, array.Buffer[AxisOffset + 1], out_index)
			AxisOffset += axis_stride
		end

		data[out_index] = Acculmulator
		out_index += 1

		local dim = array.ndim

		while dim >= 1 do
			if dim == axis then
				dim -= 1
				continue
			end

			index[dim] += 1
			Offset += array.Strides[dim]

			if index[dim] < array.Shape[dim] then break end

			index[dim] = 0
			Offset -= array.Shape[dim] * array.Strides[dim]

			dim -= 1
		end

		if dim < 1 then break end
	end

	local OutputShape = table.clone(array.Shape)
	table.remove(OutputShape, axis)

	local OutputStrides = ndArray_utils.ComputeStrides(OutputShape)

	return ndArray(data, OutputShape, OutputStrides, 0, typeof(initValue))
end

--- Applies a sum aggregation either across the entire ndArray or across a specified axis
---@within numluau
---@method sum
---@param array ndArray
---@param axis number
---@return ndArray
function module.sum(array, axis)
	return Aggregate(array, axis, 0, function(A, B)
		return A + B
	end)
end

--- Applies a prod aggregation either across the entire ndArray or across a specified axis
---@within numluau
---@method prod
---@param array ndArray
---@param axis number
---@return ndArray
function module.prod(array, axis)
	return Aggregate(array, axis, 1, function(A, B)
		return A * B
	end)
end

--- Creates a ndarray of the minimum values of either the entire ndArray or over a specified axis
---@within numluau
---@method min
---@param array ndArray
---@param axis number
---@return ndArray
function module.min(array, axis)
	return Aggregate(array, axis, math.huge, function(A, B)
		return math.min(A, B)
	end)
end

--- Creates a ndarray of the maximum values of either the entire ndArray or over a specified axis
---@within numluau
---@method max
---@param array ndArray
---@param axis number
---@return ndArray
function module.max(array, axis)
	return Aggregate(array, axis, 0, function(A, B)
		return math.max(A, B)
	end)
end

--- Creates a ndarray of the mean values of either the entire ndArray or over a specified axis
---@within numluau
---@method mean
---@param array ndArray
---@param axis number
---@return ndArray
function module.mean(array, axis)
	local sum = Aggregate(array, axis, 0, function(A, B)
		return A + B
	end)
	if axis == nil then return sum / #array.Buffer end

	return sum / array.Shape[#array.Shape - axis]
end

--- Creates a ndarray of the variances across either the entire ndArray or over a specified axis
---@within numluau
---@method var
---@param array ndArray
---@param axis number
---@return ndArray
function module.var(array, axis)
	local mean = module.mean(array, axis)

	if axis == nil then
		local sum2_diff = 0
		for i = 1, #array.Buffer do
			sum2_diff += (array.Buffer[i] - mean) ^ 2
		end

		return (sum2_diff / #array.Buffer)
	end

	local variance = Aggregate(array, axis, 0, function(a, b, index)
		return a + (b - mean.Buffer[index]) ^ 2
	end)

	variance /= array.Shape[array.ndim - axis]
	return variance
end

--- Creates a ndarray of the standard deviations across either the entire ndArray or across a specified axis
---@within numluau
---@method std
---@param array ndArray
---@param axis number
---@return ndArray
function module.std(array, axis)
	return module.var(array, axis) ^ 0.5
end

return module :: {
	sum: (Array: types.ndArray<any>, Axis: number?) -> types.ndArray<any>,
	prod: (Array: types.ndArray<any>, Axis: number?) -> types.ndArray<any>,
	min: (Array: types.ndArray<any>, Axis: number?) -> types.ndArray<any>,
	max: (Array: types.ndArray<any>, Axis: number?) -> types.ndArray<any>,

	mean: (Array: types.ndArray<any>, Axis: number?) -> types.ndArray<any>,
	var: (Array: types.ndArray<any>, Axis: number?) -> types.ndArray<any>,
	std: (Array: types.ndArray<any>, Axis: number?) -> types.ndArray<any>,
}
