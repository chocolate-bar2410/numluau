--!strict
local types = require("./types")
local polynomial = require("@self/polynomial")
local poly_utils = require("./utility/poly")
local module = {}

--- The polynomial module of numluau.
---@class polynomial_inter

--- constructs a polynomial with degree `degree` which fits the datapoints defined by x and y.
---@within polynomial
---@method fit
---@param x ndArray
---@param y ndArray
---@return Polynomial
module.fit = function(x: types.ndArray<number>, y: types.ndArray<number>, degree: number)
	local coef = poly_utils.fit(x, y, degree)

	return polynomial.new(coef, {
		math.min(unpack(x:toflatlist())),
		math.max(unpack(x:toflatlist())),
	})
end

--- constructs a polynomial from its roots.
---@within polynomial_inter
---@method fromroots
---@param roots {number}
---@return Polynomial
module.fromroots = function(roots: { number })
	local coef = { 1 }

	for _, root in ipairs(roots) do
		local new_coef = table.create(#coef + 1, 0)

		for i = 1, #coef do
			new_coef[i] -= coef[i] * root
			new_coef[i + 1] += coef[i]
		end

		coef = new_coef
	end

	return polynomial.new(coef)
end

--- set whether to use ascii or unicode characters when stringifying polynomials.
---@within polynomial_inter
---@method set_printstyle
---@param printstyle "ascii" | "unicode"
---@return Polynomial
module.set_printstyle = function(printstyle: poly_utils.printstyle)
	poly_utils.printstyle = printstyle
end

return setmetatable(module, {
	__call = function(_, coef: { number }, domain: { number }, window: { number }, symbol: string): types.Polynomial
		return polynomial.new(coef, domain, window, symbol) :: types.Polynomial
	end,
}) :: setmetatable<{
	fit: (x: types.ndArray<number>, y: types.ndArray<number>, degree: number) -> types.Polynomial,
	fromroots: (roots: { number }) -> types.Polynomial,
	set_printstyle: (printstyle: poly_utils.printstyle) -> (),
}, {
	__call: (coef: { number }, domain: { number }, window: { number }, symbol: string) -> types.Polynomial,
}>
