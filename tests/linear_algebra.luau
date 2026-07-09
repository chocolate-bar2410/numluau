local unit_tests = require("./unit_test")
local numluau = require("../numluau")

unit_tests.Test("matrix multiplication",function()
    local A = numluau.array({{2,0,0},{0,2,0}})
    local B = numluau.array({1,2,3})

    local C = numluau.linalg.matmul(A, B)

    unit_tests.AssertEquals(C:toflatlist(),{2,4})
    unit_tests.AssertEquals(C.Shape,{2})
    unit_tests.AssertEquals(C.Strides,{1})


    A = numluau.array({{2,0,0},{0,2,0}})
    B = numluau.array({{1,0,0,0},{0,1,0,0},{0,1,0,0}})

    C = numluau.linalg.matmul(A, B)
    unit_tests.AssertEquals(C:toflatlist(),{2,0,0,0,0,2,0,0})
    unit_tests.AssertEquals(C.Shape,{2,4})
    unit_tests.AssertEquals(C.Strides,{4,1})

    A = numluau.array({{1,0,0},{0,1,0},{0,0,1}})
    B = numluau.array({{1,2,3},{1,2,3},{1,2,3}})

    C = numluau.linalg.matmul(A, B)
    unit_tests.AssertEquals(C:toflatlist(),{1,2,3,1,2,3,1,2,3})
    unit_tests.AssertEquals(C.Shape,{3,3})
    unit_tests.AssertEquals(C.Strides,{3,1})

    A = numluau.array({{1,0,0,0}})
    B = numluau.array({{1,2,3},{1,2,3},{1,2,3}})

    unit_tests.AssertError(numluau.linalg.matmul,A, B)

    A = numluau.array({{2,0},{0,2}})
    B = numluau.array({{1,0,0,0},{0,1,0,0},{0,1,0,0}})

    unit_tests.AssertError(numluau.linalg.matmul,A, B)

end)


unit_tests.ProcessResults()
