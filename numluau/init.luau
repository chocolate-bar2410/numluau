local FromTable = require("@self/ndarray/FromTable")
local ndArray_utils = require("@self/utility/ndarray")
local math_utils = require("@self/math/luau_math")
local aggregations = require("@self/math/aggregations")
local constructors = require("@self/ndarray/constructors")

local comparison = require("@self/logical/comparison")
local logical = require("@self/logical/logical")

local calculus = require("@self/math/calculus")

local table_utils = require("@self/utility/table")
local poly_utils = require("@self/utility/poly")
--[[
to do:
    
reference:
    - https://www.youtube.com/watch?v=VXU4LSAQDSc
    - https://www.youtube.com/watch?v=DcfYgePyedM
]]

local types = require("@self/types")

export type ndArray<T> = types.ndArray<T>
export type Generator = types.Generator
export type Polynomial = types.Polynomial

--- The numluau library.
---@class numluau
---The version of numluau.
---@prop version Version

--- A object that represents the version of numluau.
---@class Version
---@prop major number
---@prop minor number

local Base = {
	array = FromTable,

	linalg = require("@self/math/lin_algebra"),
	random = require("@self/random"),
	polynomial = require("@self/polynomial"),
	version = { major = 1, minor = 1 } :: types.Version,

	--- configures the prettyprint of the library.
	--- |property	 | description 																			 | default value|
	--- |------------|---------------------------------------------------------------------------------------|--------------|
	--- | suppress   | suppresses small numbers 															 | false   		|
	--- | precission | the precission of the numbers 														 | 8 d.p   		|
	--- | threshold  | the number of values, a ndarray it can have per row before its tostring is truncated. | 100 	   		|
	--- | edge items | the ammount of items that show up when a ndarray's tostring is truncated. 			 | 3 	   		|
	--- | line width | the max ammount of characters before a ndarray's tostring is wrapped around. 		 | 75	   		|
	---@within numluau
	---@method set_printoptions
	---@param args {suppress: boolean,precision: number,threshold: number,edgeitems: number,linewidth: number}
	set_printoptions = function(args: {
		suppress: boolean,
		precision: number,
		threshold: number,
		edgeitems: number,
		linewidth: number,
	})
		ndArray_utils.suppress = if args.suppress ~= nil then args.suppress else ndArray_utils.suppress
		ndArray_utils.precision = if args.precision ~= nil then args.precision else ndArray_utils.precision

		ndArray_utils.edgeitems = if args.edgeitems ~= nil then args.edgeitems else ndArray_utils.edgeitems
		ndArray_utils.threshold = if args.threshold ~= nil then args.threshold else ndArray_utils.threshold
		ndArray_utils.linewidth = if args.linewidth ~= nil then args.linewidth else ndArray_utils.linewidth

		poly_utils.suppress = if args.suppress ~= nil then args.suppress else poly_utils.suppress
		poly_utils.precision = if args.precision ~= nil then args.precision else poly_utils.precision
	end,
}

type out =
	typeof(Base)
	& typeof(math_utils)
	& typeof(aggregations)
	& typeof(comparison)
	& typeof(logical)
	& typeof(calculus)
	& typeof(constructors)

return table_utils.merge(Base, math_utils, aggregations, comparison, logical, calculus, constructors) :: out
