--!native
--!strict
local module = {}

local log = math.log
local pi = math.pi
local sin = math.sin

local rshift = bit32.rshift
local band = bit32.band
local lshift = bit32.lshift

local lancozs_coeff = {
	0.99999999999980993,
	676.5203681218851,
	-1259.1392167224028,
	771.32342877765313,
	-176.61502916214059,
	12.507343278686905,
	-0.13857109526572012,
	9.9843695780195716e-6,
	1.5056327351493116e-7,
}
-- multiplies two 32 bit numbers into a 64 bit number
-- return values represent the top and bottom bits
module.multiply32 = function(x1: number, x2: number): (number, number)
	local x1_low = band(x1, 0xFFFF)
	local x2_low = band(x2, 0xFFFF)

	local x1_high = rshift(x1, 16)
	local x2_high = rshift(x2, 16)

	local p00 = x1_low * x2_low
	local p01 = x1_low * x2_high
	local p10 = x1_high * x2_low
	local p11 = x1_high * x2_high

	local mid = p01 + p10
	local mid_low = band(mid, 0xFFFF)
	local mid_high = rshift(mid, 16)

	local low = band(p00 + lshift(mid_low, 16), 0xFFFFFFFF)

	local carry = rshift(p00 + lshift(mid_low, 16), 32)

	local high = band(p11 + mid_high + carry, 0xFFFFFFFF)

	return high, low
end

module.log_fact = function(x1: number): number
	if x1 < 20 then
		local result = 1
		for i = 1, x1 do
			result *= i
		end

		return log(result)
	else
		-- stirling's aproximation
		local result = x1 * log(x1) - x1 + 0.5 * log(2 * pi * x1)
		return result
	end
end

module.log_gamma = function(x1: number): number
	if x1 < 0.5 then
		-- reflection formula
		return log(pi) - log(sin(pi * x1)) - module.log_gamma(1 - x1)
	end

	-- lancosz approximation
	local g = 7

	local x = x1 + 1
	local AgX = lancozs_coeff[1]

	for i = 2, #lancozs_coeff do
		AgX += lancozs_coeff[i] / (x + i - 1)
	end

	local z = x + g + 0.5
	local HALF_LN_2PI = 0.9189385332046727

	return HALF_LN_2PI + (x + 0.5) + log(z) - z + log(AgX)
end

return module
