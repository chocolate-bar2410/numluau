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

    x[1] = 125
    x[2] = -30

    unit_tests.AssertEquals(x[1], 125)
    unit_tests.AssertEquals(x[2], -30)
end)

unit_tests.Test("negative indexing",function()
    local x = numluau.array({1,2,3,4,5})
    local meta = getmetatable(x)

    unit_tests.AssertEquals(x[-1], 5)
    unit_tests.AssertEquals(x[-2], 4)
    unit_tests.AssertEquals(x[-3], 3)

    unit_tests.AssertError(meta.__index,x, -6)
    unit_tests.AssertError(meta.__index,x, -2.5)

    x[-1] = 125
    x[-2] = -30

    unit_tests.AssertEquals(x[5], 125)
    unit_tests.AssertEquals(x[4], -30)
end)

unit_tests.Test("1d slicing",function()
    local x = numluau.array({1,2,3,4,5})

    local meta = getmetatable(x)

    unit_tests.AssertEquals(x["1:3"]:toflatlist(), {1,2,3})
    unit_tests.AssertEquals(x["1:5:2"]:toflatlist(), {1,3,5})

    unit_tests.AssertEquals(x["1:3:-1"]:toflatlist(), {3,2,1})
    unit_tests.AssertEquals(x["1:-1"]:toflatlist(), {1,2,3,4,5})

    unit_tests.AssertEquals(x["::1"]:toflatlist(), {1,2,3,4,5})
    unit_tests.AssertEquals(x["::-1"]:toflatlist(), {5,4,3,2,1})

    x["1:3"] = numluau.array({10,20,30})
    unit_tests.AssertEquals(x:toflatlist(), {10,20,30,4,5})

    x["1:3"] = 15
    unit_tests.AssertEquals(x:toflatlist(), {15,15,15,4,5})

    unit_tests.AssertError(meta.__newindex,x,"1:2",numluau.array({1,2,3,4,5,6}))
end)

unit_tests.ProcessResults()