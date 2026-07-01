--!strict
local module = {}

-- multiplies two 32 bit numbers into a 64 bit number
-- return values represent the top and bottom bits
module.multiply32 = function(x1 : number,x2 : number) : (number,number)
    local x1_low = bit32.band(x1,0xFFFF)
    local x2_low = bit32.band(x2,0xFFFF)

    local x1_high = bit32.rshift(x1,16)
    local x2_high = bit32.rshift(x2,16)

    local p00 = x1_low * x2_low
    local p01 = x1_low * x2_high
    local p10 = x1_high * x2_low
    local p11 = x1_high * x2_high

    local mid = p01 + p10
    local mid_low = bit32.band(mid,0xFFFF)
    local mid_high = bit32.rshift(mid,16)

    local low = bit32.band(p00 + bit32.lshift(mid_low, 16),0xFFFFFFFF)

    local carry = bit32.rshift(p00 + bit32.lshift(mid_low, 16),32)

    local high = bit32.band(p11 + mid_high + carry,0xFFFFFFFF)

    return high,low
end


return module
