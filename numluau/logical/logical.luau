local module = {}
local types = require("../types")
local Broadcast = require("../ndarray/Broadcast")
local ndArray_utils = require("../utility/ndarray")
local ndArray = require("../ndarray/ndarray")

--- Creates a boolean ndArray by applying a logical `and` between x1 and x2
---@within numluau
---@param x1 ndArray
---@param x2 ndArray
---@return ndArray
function module.logical_and(x1: types.ndArray<any>, x2: types.ndArray<any>)
	local Result, OutShape = Broadcast.CreateBroadcastArray(x1, x2, function(a, b)
		a = a ~= 0 and a ~= false
		b = b ~= 0 and b ~= false
		return a and b
	end)
	Result = ndArray(Result, OutShape, ndArray_utils.ComputeStrides(OutShape), 0, "boolean")

	return Result
end

--- Creates a boolean ndArray by applying a logical `or` between x1 and x2
---@within numluau
---@param x1 ndArray
---@param x2 ndArray
---@return ndArray
function module.logical_or(x1: types.ndArray<any>, x2: types.ndArray<any>)
	local Result, OutShape = Broadcast.CreateBroadcastArray(x1, x2, function(a, b)
		a = a ~= 0 and a ~= false
		b = b ~= 0 and b ~= false
		return a or b
	end)
	Result = ndArray(Result, OutShape, ndArray_utils.ComputeStrides(OutShape), 0, "boolean")

	return Result
end

--- Creates a boolean ndArray by applying a logical `xor` between x1 and x2
---@within numluau
---@param x1 ndArray
---@param x2 ndArray
---@return ndArray
function module.logical_xor(x1: types.ndArray<any>, x2: types.ndArray<any>)
	local Result, OutShape = Broadcast.CreateBroadcastArray(x1, x2, function(a, b)
		a = a ~= 0 and a ~= false
		b = b ~= 0 and b ~= false
		return a ~= b
	end)
	Result = ndArray(Result, OutShape, ndArray_utils.ComputeStrides(OutShape), 0, "boolean")

	return Result
end

--- Creates a boolean ndArray by applying a logical `not` on x1
---@within numluau
---@param x1 ndArray
---@return ndArray
function module.logical_not(x1: types.ndArray<boolean>)
	local Result = x1:copy()
	Result.dtype = "boolean"

	for i, v in x1 do
		local value = v

		if v == 0 then value = false end
		if v == 1 then value = true end

		if type(value) == "boolean" then
			Result.Buffer[i] = not value
			continue
		end
	end

	return Result
end

return module :: {
	logical_and: (x1: types.ndArray<any>, x2: types.ndArray<any>) -> types.ndArray<boolean>,
	logical_or: (x1: types.ndArray<any>, x2: types.ndArray<any>) -> types.ndArray<boolean>,
	logical_xor: (x1: types.ndArray<any>, x2: types.ndArray<any>) -> types.ndArray<boolean>,
	logical_not: (x1: types.ndArray<any>) -> types.ndArray<boolean>,
}
