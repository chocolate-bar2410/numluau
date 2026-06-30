--!strict
local module = {}

module.XORSHIRO128 = function(seed : number)
    local state0 = 0
    local state1 = 0
    local state2 = 0
    local state3 = 0
end

module.Philox = function(seed : number)
    
end

-- 32bit version of PCG64DXM since 64 bit ints are apparently a roblox only feature
module.PCGXSH = function(seed : number) : () -> number
    local state = 0

    --PCG32 constants
    local MULTIPLIER : number = 747796405
    local INCREMENT : number = 2891336453

    state = bit32.band(state * 747796405 + INCREMENT, 0xFFFFFFFF)
    state = (state + seed)
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