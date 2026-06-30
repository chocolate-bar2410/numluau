--!strict
local module = {}
local GOLD = 0x9E3779B9
local SILVER = 0xBB67AE85

-- utility function to start up seeds
local splitmix32 = function(seed : number)
    local result = seed + GOLD
    result = bit32.bxor(result,bit32.rshift(result, 16)) * 0x85EBCA6B
    result = bit32.bxor(result,bit32.rshift(result, 13)) * 0xC2B2AE35

    return bit32.bxor(result,bit32.rshift(result, 16))
end

-- this uses xoshiro128**
module.XOSHIRO128 = function(seed : number) : () -> number
    seed = seed or math.round(os.clock())
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

-- fast and small
module.SFC32 = function(seed : number) : () -> number
    seed = seed or math.round(os.clock())
    local a = splitmix32(seed)
    local b = splitmix32(seed + GOLD)
    local c = splitmix32(seed + SILVER)

    local counter = 1

    return function()
        local result = bit32.band(a + b + counter,0xFFFFFFFF)
        counter = bit32.band(counter + 1,0xFFFFFFFF)

        a = bit32.bxor(b, bit32.rshift(b, 9))
        b = bit32.band(c + bit32.rshift(b, 3),0xFFFFFFFF)
        c = bit32.band(bit32.lrotate(c, 21) + result ,0xFFFFFFFF)

        return result
    end
end

-- philox 2x32 implementation
module.Philox = function(seed : number) : () -> number
    seed = seed or math.round(os.clock())
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
        counter = bit32.band(counter + 1, 0xFFFFFFFF)

        local k = key
        for i = 1,10 do
            local prod = c0 * 0xED5AD4BB
            local low = bit32.band(prod,0xFFFFFFFF)
            local high = (prod // 0x100000000) % 0x100000000

            c0 = bit32.bxor(bit32.bxor(high, c1), k)
            c1 = low
            k = bit32.band(k + GOLD,0xFFFFFFFF)
        end

        _buffer = c1
        has_buffer = true

        return c0
    end
end

-- use if you like having no bad seeds
module.JSF32 = function(seed : number) : () -> number
    seed = seed or math.round(os.clock())
    
    local a = 0xf1ea5eed
    local b = splitmix32(seed)
    local c = splitmix32(seed + GOLD)
    local d = splitmix32(seed + SILVER)

    -- to wash out the initial seeding
    for i = 1,20 do
        local e = bit32.band(a - bit32.lrotate(b, 27),0xFFFFFFFF)
        a = bit32.bxor(b, bit32.lrotate(c, 17))
        b = bit32.band(c + d,0xFFFFFFFF)
        c = bit32.band(d + e,0xFFFFFFFF)
        d = bit32.band(e + a,0xFFFFFFFF)
    end

    return function()
        local e = bit32.band(a - bit32.lrotate(b, 27),0xFFFFFFFF)
        a = bit32.bxor(b, bit32.lrotate(c, 17))
        b = bit32.band(c + d,0xFFFFFFFF)
        c = bit32.band(d + e,0xFFFFFFFF)
        d = bit32.band(e + a,0xFFFFFFFF)

        return d
    end
end

-- 32bit version of PCG64DXSM since 64 bit ints are apparently a roblox only feature
module.PCGXSH = function(seed : number) : () -> number
    seed = seed or math.round(os.clock())
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