--!native
--!strict
local module = {}
local GOLD = 0x9E3779B9
local SILVER = 0xBB67AE85

local round = math.round
local bxor = bit32.bxor
local rshift = bit32.rshift
local band = bit32.band
local lrotate = bit32.lrotate
local lshift = bit32.lshift
local rrotate = bit32.rrotate
-- utility function to start up seeds
local splitmix32 = function(seed: number)
	local result = seed + GOLD
	result = bxor(result, rshift(result, 16)) * 0x85EBCA6B
	result = bxor(result, rshift(result, 13)) * 0xC2B2AE35

	return bxor(result, rshift(result, 16))
end

-- this uses xoshiro128**
--- returns a bit generator that produces numbers using XOSHIRO128.
---@within random
---@method XOSHIRO128
---@param seed number
---@return () -> number
module.XOSHIRO128 = function(seed: number): () -> number
	seed = seed or round(os.clock())
	local s1 = seed
	local s2 = splitmix32(seed)
	local s3 = splitmix32(seed + GOLD)
	local s4 = splitmix32(seed + (GOLD * 2))

	return function()
		local result = band((lrotate((s2 * 5), 7) * 9), 0xFFFFFFFF)

		local temp = lshift(s2, 9)

		s3 = bxor(s3, s1)
		s4 = bxor(s4, s2)
		s2 = bxor(s2, s3)
		s1 = bxor(s1, s4)

		s3 = bxor(s3, temp)
		s4 = lrotate(s4, 11)

		return result
	end
end

-- fast and small
--- returns a bit generator that produces numbers using SFC32.
---@within random
---@method SFC32
---@param seed number
---@return () -> number
module.SFC32 = function(seed: number): () -> number
	seed = seed or round(os.clock())
	local a = splitmix32(seed)
	local b = splitmix32(seed + GOLD)
	local c = splitmix32(seed + SILVER)

	local counter = 1

	return function()
		local result = band(a + b + counter, 0xFFFFFFFF)
		counter = band(counter + 1, 0xFFFFFFFF)

		a = bxor(b, rshift(b, 9))
		b = band(c + rshift(b, 3), 0xFFFFFFFF)
		c = band(lrotate(c, 21) + result, 0xFFFFFFFF)

		return result
	end
end

-- philox 2x32 implementation
--- returns a bit generator that produces numbers using Philox.
---@within random
---@method Philox
---@param seed number
---@return () -> number
module.Philox = function(seed: number): () -> number
	seed = seed or round(os.clock())
	local key = seed
	local counter = 0
	local _buffer = 0
	local has_buffer = false

	return function()
		if has_buffer then
			has_buffer = false
			return _buffer
		end

		local c0 = counter
		local c1 = 0
		counter = band(counter + 1, 0xFFFFFFFF)

		local k = key
		for i = 1, 10 do
			local prod = c0 * 0xED5AD4BB
			local low = band(prod, 0xFFFFFFFF)
			local high = (prod // 0x100000000) % 0x100000000

			c0 = bxor(bxor(high, c1), k)
			c1 = low
			k = band(k + GOLD, 0xFFFFFFFF)
		end

		_buffer = c1
		has_buffer = true

		return c0
	end
end

-- use if you like having no bad seeds
--- returns a bit generator that produces numbers using JSF32.
---@within random
---@method JSF32
---@param seed number
---@return () -> number
module.JSF32 = function(seed: number): () -> number
	seed = seed or round(os.clock())

	local a = 0xf1ea5eed
	local b = splitmix32(seed)
	local c = splitmix32(seed + GOLD)
	local d = splitmix32(seed + SILVER)

	-- to wash out the initial seeding
	for i = 1, 20 do
		local e = band(a - lrotate(b, 27), 0xFFFFFFFF)
		a = bxor(b, lrotate(c, 17))
		b = band(c + d, 0xFFFFFFFF)
		c = band(d + e, 0xFFFFFFFF)
		d = band(e + a, 0xFFFFFFFF)
	end

	return function()
		local e = band(a - lrotate(b, 27), 0xFFFFFFFF)
		a = bxor(b, lrotate(c, 17))
		b = band(c + d, 0xFFFFFFFF)
		c = band(d + e, 0xFFFFFFFF)
		d = band(e + a, 0xFFFFFFFF)

		return d
	end
end

-- 32bit version of PCG64DXSM since 64 bit ints are apparently a roblox only feature
--- returns a bit generator that produces numbers using PCGXSH.
---@within random
---@method PCGXSH
---@param seed number
---@return () -> number
module.PCGXSH = function(seed: number): () -> number
	seed = seed or round(os.clock())
	local state = 0

	--PCG32 constants
	local MULTIPLIER: number = 747796405
	local INCREMENT: number = 2891336453

	state = band(state * 747796405 + INCREMENT, 0xFFFFFFFF)
	state += seed
	state = band(state * 747796405 + INCREMENT, 0xFFFFFFFF)

	return function()
		local newstate = band(state * MULTIPLIER + INCREMENT, 0xFFFFFFFF)

		local xorshift = rshift(bxor(rshift(state, 18), state), 27)
		local rot = rshift(state, 27)

		local result = rrotate(xorshift, rot)

		state = newstate
		return result
	end
end

return module
