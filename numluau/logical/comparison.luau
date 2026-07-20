local module = {}
local types = require("../types")
local Broadcast = require("../ndarray/Broadcast")
local ndArray_utils = require("../utility/ndarray")
local ndArray = require("../ndarray/ndarray")

--- compares x1 and x2 and creates a boolean ndArray.
--- using the comparison x1 > x2
---@within numluau
---@method greater
---@param x1 ndArray
---@param x2 ndArray
---@return ndArray
function module.greater(x1: types.ndArray<any>, x2: types.ndArray<any>)
	local Result, OutShape = Broadcast.CreateBroadcastArray(x1, x2, function(a, b)
		return a > b
	end)
	Result = ndArray(Result, OutShape, ndArray_utils.ComputeStrides(OutShape), 0, "boolean")

	return Result
end

--- compares x1 and x2 and creates a boolean ndArray.
--- using the comparison x1 ≥ x2
---@within numluau
---@method greater_equal
---@param x1 ndArray
---@param x2 ndArray
---@return ndArray
function module.greater_equal(x1: types.ndArray<any>, x2: types.ndArray<any>)
	local Result, OutShape = Broadcast.CreateBroadcastArray(x1, x2, function(a, b)
		return a >= b
	end)
	Result = ndArray(Result, OutShape, ndArray_utils.ComputeStrides(OutShape), 0, "boolean")

	return Result
end

--- compares x1 and x2 and creates a boolean ndArray.
--- using the comparison x1 < x2
---@within numluau
---@method less
---@param x1 ndArray
---@param x2 ndArray
---@return ndArray
function module.less(x1: types.ndArray<any>, x2: types.ndArray<any>)
	local Result, OutShape = Broadcast.CreateBroadcastArray(x1, x2, function(a, b)
		return a < b
	end)
	Result = ndArray(Result, OutShape, ndArray_utils.ComputeStrides(OutShape), 0, "boolean")

	return Result
end

--- compares x1 and x2 and creates a boolean ndArray.
--- using the comparison x1 ≤ x2
---@within numluau
---@method less_equal
---@param x1 ndArray
---@param x2 ndArray
---@return ndArray
function module.less_equal(x1: types.ndArray<any>, x2: types.ndArray<any>)
	local Result, OutShape = Broadcast.CreateBroadcastArray(x1, x2, function(a, b)
		return a <= b
	end)
	Result = ndArray(Result, OutShape, ndArray_utils.ComputeStrides(OutShape), 0, "boolean")

	return Result
end

--- compares x1 and x2 and creates a boolean ndArray.
--- using the comparison x1 = x2
---@within numluau
---@method equal
---@param x1 ndArray
---@param x2 ndArray
---@return ndArray
function module.equal(x1: types.ndArray<any>, x2: types.ndArray<any>)
	local Result, OutShape = Broadcast.CreateBroadcastArray(x1, x2, function(a, b)
		return a == b
	end)
	Result = ndArray(Result, OutShape, ndArray_utils.ComputeStrides(OutShape), 0, "boolean")

	return Result
end

--- compares x1 and x2 and creates a boolean ndArray.
--- using the comparison x1 ≠ x2
---@within numluau
---@method not_equal
---@param x1 ndArray
---@param x2 ndArray
---@return ndArray
function module.not_equal(x1: types.ndArray<any>, x2: types.ndArray<any>)
	local Result, OutShape = Broadcast.CreateBroadcastArray(x1, x2, function(a, b)
		return a ~= b
	end)
	Result = ndArray(Result, OutShape, ndArray_utils.ComputeStrides(OutShape), 0, "boolean")

	return Result
end

return module :: {
	greater: (x1: types.ndArray<any>, x2: types.ndArray<any>) -> types.ndArray<boolean>,
	greater_equal: (x1: types.ndArray<any>, x2: types.ndArray<any>) -> types.ndArray<boolean>,
	less: (x1: types.ndArray<any>, x2: types.ndArray<any>) -> types.ndArray<boolean>,
	less_equal: (x1: types.ndArray<any>, x2: types.ndArray<any>) -> types.ndArray<boolean>,
	equal: (x1: types.ndArray<any>, x2: types.ndArray<any>) -> types.ndArray<boolean>,
	not_equal: (x1: types.ndArray<any>, x2: types.ndArray<any>) -> types.ndArray<boolean>,
}
