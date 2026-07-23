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


    local polyE : numluau.Polynomial = numluau.polynomial({})
    unit_tests.AssertEquals(polyE.coef:toflatlist(),{})

    local polyF : numluau.Polynomial = numluau.polynomial({0,0,0})
    unit_tests.AssertEquals(polyF.coef:toflatlist(),{0,0,0})
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

    polyA.symbol = "y"
    local meta = getmetatable(polyA)

    unit_tests.AssertError(meta.__add,polyA,polyB)
    unit_tests.AssertError(meta.__sub,polyA,polyB)
    unit_tests.AssertError(meta.__mul,polyA,polyB)
    unit_tests.AssertError(meta.__idiv,polyA,polyB)

    unit_tests.AssertError(meta.__idiv,polyA,numluau.polynomial({0,0,0}))
end)

unit_tests.Test("polynomial evaluation",function()
    local polyA : numluau.Polynomial = numluau.polynomial({9,6,1})
    local x : numluau.ndArray<number> = numluau.arange(5)

    unit_tests.AssertEquals(polyA(5),64)
    unit_tests.AssertEquals(polyA(x):toflatlist(),{16,25,36,49,64})

    unit_tests.AssertEquals(polyA(1,2,3,4,5):toflatlist(),{16,25,36,49,64})
end)

unit_tests.Test("degree",function()
    local polyA : numluau.Polynomial = numluau.polynomial({9,6,1})
    unit_tests.AssertEquals(polyA:degree(), 2)

    local polyB : numluau.Polynomial = numluau.polynomial({1,2,3,0})
    unit_tests.AssertEquals(polyB:degree(),2)

    local polyC : numluau.Polynomial = numluau.polynomial({1,2,3,4,5,6})
    unit_tests.AssertEquals(polyC:cutdeg(3).coef:toflatlist(),{1,2,3,4})
end)

unit_tests.Test("polynomial calculus",function()
    local polyA : numluau.Polynomial = numluau.polynomial({9,6,1})    
    unit_tests.AssertEquals(polyA:deriv().coef:toflatlist(), {6,2})

    local polyB : numluau.Polynomial = numluau.polynomial({5})
    unit_tests.AssertEquals(polyB:deriv().coef:toflatlist(), {0})

    local polyC : numluau.Polynomial = numluau.polynomial({1,2})
    unit_tests.AssertEquals(polyC:integ().coef:toflatlist(), {0,1,1})
end)

unit_tests.Test("polynomial companion",function()
    local polyA : numluau.Polynomial = numluau.polynomial({9,6,1})    
    local companionA = polyA:companion()

    unit_tests.AssertEquals(companionA[2][1], 1)
    unit_tests.AssertEquals(companionA[1][2], -9)
    unit_tests.AssertEquals(companionA[2][2], -6)

    local polyB : numluau.Polynomial = numluau.polynomial({1,2})
    unit_tests.AssertError(polyB.companion,polyB)
end)


unit_tests.Test("polynomial roots",function()
    local polyA : numluau.Polynomial = numluau.polynomial({2,4})    
    unit_tests.AssertEquals(polyA:roots():toflatlist(), numluau.array(-0.5):toflatlist())

    local polyB : numluau.Polynomial = numluau.polynomial({1,2,1})    
    unit_tests.AssertEquals(polyB:roots():toflatlist(), numluau.array({-1,-1}):toflatlist())
end)


unit_tests.ProcessResults()