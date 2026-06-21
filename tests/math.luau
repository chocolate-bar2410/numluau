--!strict
local unit_tests = require("./unit_test")
local numluau = require("@numluau")

unit_tests.Test("operations on floats",function()
    local input = numluau.array({-2.7, -0.5, 0, 1.2, 3.9})
    
    local abs_result = numluau.abs(input)
    unit_tests.AssertEquals(abs_result.Buffer, {2.7, 0.5, 0, 1.2, 3.9})
    
    local floor_result = numluau.floor(input)
    unit_tests.AssertEquals(floor_result.Buffer, {-3, -1, 0, 1, 3})
    
    local ceil_result = numluau.ceil(input)
    unit_tests.AssertEquals(ceil_result.Buffer, {-2, 0, 0, 2, 4})
    
    local sign_result = numluau.sign(input)
    unit_tests.AssertEquals(sign_result.Buffer, {-1, -1, 0, 1, 1})

    local round_result = numluau.round(input)
    unit_tests.AssertEquals(round_result.Buffer, {-3, -1, 0, 1, 4})
end)

unit_tests.Test("trignometry", function()
    local deg_input = numluau.array({0,90,180})

    local rad_result = numluau.rad(deg_input)
    local deg_result = numluau.deg(rad_result)

    unit_tests.AssertEquals(rad_result.Buffer,{0,math.pi / 2,math.pi})
    unit_tests.AssertEquals(deg_result.Buffer,{0,90,180})

    local sin_result = numluau.sin(rad_result)
    local cos_result = numluau.cos(rad_result)

    unit_tests.AssertAproxEquals(sin_result.Buffer,{0,1,0})
    unit_tests.AssertAproxEquals(cos_result.Buffer,{1,0,-1})
end)

unit_tests.PrintResults()