local numluau = require("../numluau")
local unit_tests = require("./unit_test")

unit_tests.Test("number indexing",function()
    local x = numluau.array({1,2,3,4,5})
    local meta = getmetatable(x)

    unit_tests.AssertEquals(x[1], 1)
    unit_tests.AssertEquals(x[2], 2)
    unit_tests.AssertEquals(x[3], 3)

    unit_tests.AssertError(meta.__index,x, 6)
    unit_tests.AssertError(meta.__index,x, 2.5)
end)


unit_tests.ProcessResults()