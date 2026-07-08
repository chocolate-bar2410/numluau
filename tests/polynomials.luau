local numluau = require("../numluau")
local unit_tests = require("./unit_test")

unit_tests.Test("polynomial construction",function()
    local polyA : numluau.Polynomial = numluau.polynomial({1,2,3,4,5})

    unit_tests.AssertEquals(polyA.coef:toflatlist(),{1,2,3,4,5})
    unit_tests.AssertEquals(polyA.domain,{-1,1})
    unit_tests.AssertEquals(polyA.window,{-1,1})
    unit_tests.AssertEquals(polyA.symbol,"x")

    local polyB : numluau.Polynomial = numluau.polynomial(numluau.array({1,2,3,4,5}))

    unit_tests.AssertEquals(polyB.coef:toflatlist(),{1,2,3,4,5})
    unit_tests.AssertEquals(polyB.domain,{-1,1})
    unit_tests.AssertEquals(polyB.window,{-1,1})
    unit_tests.AssertEquals(polyB.symbol,"x")

    local polyC : numluau.Polynomial = numluau.polynomial({1,2,3,4,5},nil,nil,"y")

    unit_tests.AssertEquals(polyC.coef:toflatlist(),{1,2,3,4,5})
    unit_tests.AssertEquals(polyC.domain,{-1,1})
    unit_tests.AssertEquals(polyC.window,{-1,1})
    unit_tests.AssertEquals(polyC.symbol,"y")

    local polyD : numluau.Polynomial = numluau.polynomial.fromroots({-3,-3})

    unit_tests.AssertEquals(polyD.coef:toflatlist(),{9,6,1})
    unit_tests.AssertEquals(polyD.domain,{-1,1})
    unit_tests.AssertEquals(polyD.window,{-1,1})
end)

unit_tests.Test("polynomial arithmetic",function()
    local polyA : numluau.Polynomial = numluau.polynomial({9,6,1})
    local polyB : numluau.Polynomial = numluau.polynomial({3,1})

    unit_tests.AssertEquals((polyA + polyB).coef:toflatlist(),{12,7,1})
    unit_tests.AssertEquals((polyA - polyB).coef:toflatlist(),{6,5,1})
    unit_tests.AssertEquals((polyA * polyB).coef:toflatlist(),{27,27,9,1})
    unit_tests.AssertEquals((polyA // polyB).coef:toflatlist(),{3,1})


    unit_tests.AssertEquals((polyA + 5).coef:toflatlist(),{14,6,1})
    unit_tests.AssertEquals((polyA - 5).coef:toflatlist(),{4,6,1})
    unit_tests.AssertEquals((polyA * 5).coef:toflatlist(),{45,30,5})
    unit_tests.AssertEquals((polyA / 5).coef:toflatlist(),{9/5,6/5,1/5})
end)

unit_tests.Test("polynomial evaluation",function()
    local polyA : numluau.Polynomial = numluau.polynomial({9,6,1})
    local x : numluau.ndArray<number> = numluau.arange(5)

    unit_tests.AssertEquals(polyA(5),64)
    unit_tests.AssertEquals(polyA(x):toflatlist(),{16,25,36,49,64})

    unit_tests.AssertEquals(polyA(1,2,3,4,5):toflatlist(),{16,25,36,49,64})
end)


unit_tests.ProcessResults()