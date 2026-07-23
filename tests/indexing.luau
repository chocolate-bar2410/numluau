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

    unit_tests.AssertEquals(x["::-2"]:toflatlist(), {5,3,1})
    unit_tests.AssertEquals(x[":3:-1"]:toflatlist(), {3,2,1})

    x["1:3"] = numluau.array({10,20,30})
    unit_tests.AssertEquals(x:toflatlist(), {10,20,30,4,5})

    x["1:3"] = 15
    unit_tests.AssertEquals(x:toflatlist(), {15,15,15,4,5})

    unit_tests.AssertError(meta.__newindex,x,"1:2",numluau.array({1,2,3,4,5,6}))
end)

unit_tests.Test("2d slicing",function()
    local x = numluau.array({
        {1,2,3},
        {4,5,6},
        {7,8,9},
    })

    unit_tests.AssertEquals(x[1][1], 1)
    unit_tests.AssertEquals(x[1][-1], 3)

    unit_tests.AssertEquals(x["1,1"], 1)

    unit_tests.AssertEquals(x["1,-1"], 3)

    unit_tests.AssertEquals(x[":,1"]:toflatlist(), {1,4,7})
    unit_tests.AssertEquals(x["1,:"]:toflatlist(), {1,2,3})

    local A : numluau.ndArray<number> = x["1:2,1:2"]
    unit_tests.AssertEquals(A:toflatlist(), {1,2,4,5})
    unit_tests.AssertEquals(A.Shape, {2,2})
    unit_tests.AssertEquals(A.Strides, {3,1})

    local B : numluau.ndArray<number> = x["2:3,2:3"]
    unit_tests.AssertEquals(B:toflatlist(), {5,6,8,9})
    unit_tests.AssertEquals(B.Shape, {2,2})
    unit_tests.AssertEquals(B.Strides, {3,1})
    unit_tests.AssertEquals(B.Offset, 4)

    local C : numluau.ndArray<number> = x["2:-1,2:-1"]
    unit_tests.AssertEquals(C:toflatlist(), {5,6,8,9})
    unit_tests.AssertEquals(C.Shape, {2,2})
    unit_tests.AssertEquals(C.Strides, {3,1})
    unit_tests.AssertEquals(C.Offset, 4)

    local D : numluau.ndArray<number> = x["1:3:2,1:3:2"]
    unit_tests.AssertEquals(D:toflatlist(), {1,3,7,9})
    unit_tests.AssertEquals(D.Shape, {2,2})
    unit_tests.AssertEquals(D.Strides, {6,2})
end)

unit_tests.ProcessResults()