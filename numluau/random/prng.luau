--!strict
local module = {}
local GOLD = 0x9E3779B9

-- utility function to start up xoshiro128**
local splitmix32 = function(seed : number)
    local result = seed + GOLD
    result = bit32.bxor(result,bit32.rshift(result, 16)) * 0x85EBCA6B
    result = bit32.bxor(result,bit32.rshift(result, 13)) * 0xC2B2AE35

    return bit32.bxor(result,bit32.rshift(result, 16))
end

-- this uses xoshiro128**
module.XOSHIRO128 = function(seed : number)
    local s1 = seed
    local s2 = splitmix32(seed)
    local s3 = splitmix32(seed + GOLD)
    local s4 = splitmix32(seed + (GOLD * 2))

    return function()
        local result = bit32.band((bit32.lrotate((s2 * 5),7) * 9),0xFFFFFFFF)

        local temp = bit32.lshift(s2, 9)

        s3 = bit32.bxor(s3,s1)
        s4 = bit32.bxor(s4,s2)
        s2 = bit32.bxor(s2,s3)
        s1 = bit32.bxor(s1,s4)

        s3 = bit32.bxor(s3,temp)
        s4 = bit32.lrotate(s4,11)

        return result
    end
end

module.Philox = function(seed : number)
    
end

-- 32bit version of PCG64DXSM since 64 bit ints are apparently a roblox only feature
module.PCGXSH = function(seed : number) : () -> number
    local state = 0

    --PCG32 constants
    local MULTIPLIER : number = 747796405
    local INCREMENT : number = 2891336453

    state = bit32.band(state * 747796405 + INCREMENT, 0xFFFFFFFF)
    state += seed
    state = bit32.band(state * 747796405 + INCREMENT, 0xFFFFFFFF)

    return function()
        local newstate = bit32.band(state * MULTIPLIER + INCREMENT,0xFFFFFFFF)

        local xorshift = bit32.rshift(bit32.bxor(bit32.rshift(state,18),state),27)
        local rot = bit32.rshift(state,27)

        local result = bit32.rrotate(xorshift,rot)

        state = newstate
        return result
    end
end



return module