local module = {}
local types = require("../types")

local utils = require("../utility/ndarray")

local exceptions = require("../Exceptions")

--- computes the numerical difference between 2 values across an axis
--- axis defaults to 0
---@within numluau
---@method diff
---@param array ndArray
---@param axis number?
---@return ndArray
module.diff = function<T>(array: types.ndArray<T>, axis: number?)
	axis = axis or 0

	if utils.is_ndarray(array) == false then
		exceptions.FormatException("Value", ("Expected ndarray got %q"):format(typeof(array)))
	end

	if typeof(axis) ~= "number" then
		exceptions.FormatException("Axis", "Axis provided must be a number")
	elseif axis < 0 then
		exceptions.FormatException("Axis", "Axis must be greater than zero")
	elseif axis > array.ndim then
		exceptions.FormatException("Axis", "Axis is out of bounds")
	end

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
	result.Strides = utils.ComputeStrides(result.Shape)
	return result
end

--- computes the gradients between 2 points numerically across an axis
--- spacing can either be a number, ndArray or a table of ndArrays
--- if no axis is provided and you've inputed multiple ndArrays for spacing.
--- it will output multiple ndArrays representing gradients across multiple spacing ndArrays.
---@within numluau
---@method gradient
---@param array ndArray
---@param spacing types.ndArray<T>? | {types.ndArray<T>?} | number?,
---@param axis number?
---@return (ndArray) | (...ndArray)
module.gradient = function<T>(
	array: types.ndArray<T>,
	spacing: types.ndArray<T>? | { types.ndArray<T>? } | number?,
	axis: number?
)
	spacing = spacing or 1

	if utils.is_ndarray(array) == false then
		exceptions.FormatException("Value", ("Expected ndarray got %q"):format(typeof(array)))
	end

	if spacing ~= nil and typeof(spacing) ~= "number" and typeof(spacing) ~= "table" then
		exceptions.FormatException(
			"Value",
			"Spacing provided must be either a number, a ndarray or a table of ndarrays"
		)
	end

	if utils.is_ndarray(array) == false then
		exceptions.FormatException("Value", ("Expected ndarray got %q"):format(typeof(array)))
	end

	if axis == nil then
		local result = {}

		for i = array.ndim - 1, 0, -1 do
			if typeof(spacing) == "number" or utils.is_ndarray(spacing) then
				table.insert(result, module.gradient(array, spacing, i))
			else
				table.insert(result, module.gradient(array, spacing[array.ndim - i], i))
			end
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
					run = spacing.Buffer[next_index] - spacing.Buffer[prev_index]
				end

				rise = array.Buffer[next_index] - array.Buffer[prev_index]
			elseif has_next then
				if typeof(spacing) == "number" then
					run = spacing
				elseif utils.is_ndarray(spacing) then
					run = spacing.Buffer[next_index] - spacing.Buffer[current]
				end

				rise = array.Buffer[next_index] - array.Buffer[current]
			else
				if typeof(spacing) == "number" then
					run = spacing
				elseif utils.is_ndarray(spacing) then
					run = spacing.Buffer[current] - spacing.Buffer[prev_index]
				end

				rise = array.Buffer[current] - array.Buffer[prev_index]
			end

			result.Buffer[current] = rise / run
		end
	end)

	return result
end

--- computes the cumulative sum between 2 values across an axis
--- axis defaults to 0
---@within numluau
---@method cumsum
---@param array ndArray
---@param axis number?
---@return ndArray
module.cumsum = function<T>(array: types.ndArray<T>, axis: number?)
	if utils.is_ndarray(array) == false then
		exceptions.FormatException("Value", ("Expected ndarray got %q"):format(typeof(array)))
	end

	if axis == nil then
		local result = array:copy()
		local sum = 0
		for i, v in array do
			sum += array.Buffer[i]
			result.Buffer[i] = sum
		end

		return result
	end

	if typeof(axis) ~= "number" then
		exceptions.FormatException("Axis", "Axis provided must be a number")
	elseif axis < 0 then
		exceptions.FormatException("Axis", "Axis must be greater than zero")
	elseif axis > array.ndim then
		exceptions.FormatException("Axis", "Axis is out of bounds")
	end

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

--- computes the cumulative product between 2 values across an axis
--- axis defaults to 0
---@within numluau
---@method cumprod
---@param array ndArray
---@param axis number?
---@return ndArray
module.cumprod = function<T>(array: types.ndArray<T>, axis: number?)
	if utils.is_ndarray(array) == false then
		exceptions.FormatException("Value", ("Expected ndarray got %q"):format(typeof(array)))
	end

	if axis == nil then
		local result = array:copy()
		local product = 1
		for i, v in array do
			product *= array.Buffer[i]
			result.Buffer[i] = product
		end

		return result
	end

	if typeof(axis) ~= "number" then
		exceptions.FormatException("Axis", "Axis provided must be a number")
	elseif axis < 0 then
		exceptions.FormatException("Axis", "Axis must be greater than zero")
	elseif axis > array.ndim then
		exceptions.FormatException("Axis", "Axis is out of bounds")
	end

	local target_axis = array.ndim - axis
	local target_shape = array.Shape[target_axis]
	local target_stride = array.Strides[target_axis]

	local result = array:copy()

	utils.ForEachSlice(array.Shape, array.Strides, axis, array.Offset, function(base: number)
		local product = 1
		local base_index = base
		for i = 1, target_shape do
			product *= array.Buffer[base_index + 1]
			result.Buffer[base_index + 1] = product

			base_index += target_stride
		end
	end)

	return result
end

export type interface = {
	diff: <T>(array: types.ndArray<T>, axis: number?) -> types.ndArray<T>,
	gradient: <T>(
		array: types.ndArray<T>,
		spacing: types.ndArray<T>? | { types.ndArray<T>? } | number?,
		axis: number?
	) -> types.ndArray<T>,
	cumsum: <T>(array: types.ndArray<T>, axis: number?) -> types.ndArray<T>,
	cumprod: <T>(array: types.ndArray<T>, axis: number?) -> types.ndArray<T>,
}

return module :: interface
