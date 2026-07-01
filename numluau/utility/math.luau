--!strict
local module = {}

local lancozs_coeff = {
    0.99999999999980993,
    676.5203681218851,
    -1259.1392167224028,
    771.32342877765313,
    -176.61502916214059,
    12.507343278686905,
    -0.13857109526572012,
    9.9843695780195716e-6,
    1.5056327351493116e-7
}
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

module.log_fact = function(x1 : number) : number
    if x1 < 20 then
        local result = 1
        for i = 1,x1 do
            result *= i
        end

        return math.log(result)
    else
        -- stirling's aproximation
        local result = x1 * math.log(x1) - x1 + 0.5 * math.log(2 * math.pi * x1)
        return result
    end
end

module.log_gamma = function(x1 : number) : number
    if x1 < 0.5 then
        -- reflection formula
        return math.log(math.pi) - math.log(math.sin(math.pi * x1)) - module.log_gamma(1 - x1)
    end

    -- lancosz approximation
    local g = 7

    local x = x1 + 1
    local AgX = lancozs_coeff[1]

    for i = 2,#lancozs_coeff do
        AgX += lancozs_coeff[i] / (x + i - 1)
    end

    local z = x + g + 0.5
    local HALF_LN_2PI = 0.9189385332046727

    return HALF_LN_2PI + (x + 0.5) + math.log(z) - z + math.log(AgX)
end


return module
