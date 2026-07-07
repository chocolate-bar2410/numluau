local unit_tests = require("./unit_test")
local numluau = require("../numluau")

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

unit_tests.Test("cummulative sum",function()
    local x : numluau.ndArray<number> = numluau.arange(1,10)

    unit_tests.AssertError(numluau.cumsum,x,"hello")
    unit_tests.AssertError(numluau.cumsum,x,-1)
    unit_tests.AssertError(numluau.cumsum,x,2)

    unit_tests.AssertError(numluau.cumsum,"testing123")

    local y : numluau.ndArray<number> = numluau.cumsum(x)
    unit_tests.AssertEquals(y:toflatlist(), {1,3,6,10,15,21,28,36,45,55})

    x = numluau.array({
        {1,2},
        {3,4}
    })

    y = numluau.cumsum(x)

    unit_tests.AssertEquals(y:toflatlist(), {1,3,6,10})
    unit_tests.AssertEquals(y.Shape, {2,2})
    unit_tests.AssertEquals(y.Strides, {2,1})

    y = numluau.cumsum(x,0)

    unit_tests.AssertEquals(y:toflatlist(), {1,3,3,7})
    unit_tests.AssertEquals(y.Shape, {2,2})
    unit_tests.AssertEquals(y.Strides, {2,1})

    y = numluau.cumsum(x,1)

    unit_tests.AssertEquals(y:toflatlist(), {1,2,4,6})
    unit_tests.AssertEquals(y.Shape, {2,2})
    unit_tests.AssertEquals(y.Strides, {2,1})
end)

unit_tests.Test("cummulative product",function()
    local x : numluau.ndArray<number> = numluau.arange(1,10)
    local y : numluau.ndArray<number> = numluau.cumprod(x)
    
    unit_tests.AssertError(numluau.cumprod,x,"hello")
    unit_tests.AssertError(numluau.cumprod,x,-1)
    unit_tests.AssertError(numluau.cumprod,x,2)

    unit_tests.AssertError(numluau.cumprod,"testing123")

    unit_tests.AssertEquals(y:toflatlist(), {1,2,6,24,120,720,5040,40320,362880,3628800})

    x = numluau.array({
        {1,2},
        {3,4}
    })

    y = numluau.cumprod(x)

    unit_tests.AssertEquals(y:toflatlist(), {1,2,6,24})
    unit_tests.AssertEquals(y.Shape, {2,2})
    unit_tests.AssertEquals(y.Strides, {2,1})

    y = numluau.cumprod(x,0)

    unit_tests.AssertEquals(y:toflatlist(), {1,2,3,12})
    unit_tests.AssertEquals(y.Shape, {2,2})
    unit_tests.AssertEquals(y.Strides, {2,1})

    y = numluau.cumprod(x,1)

    unit_tests.AssertEquals(y:toflatlist(), {1,2,3,8})
    unit_tests.AssertEquals(y.Shape, {2,2})
    unit_tests.AssertEquals(y.Strides, {2,1})
end)

unit_tests.Test("difference",function()
    local x : numluau.ndArray<number> = numluau.arange(1,10)
    local y : numluau.ndArray<number> = numluau.diff(x)
    
    unit_tests.AssertError(numluau.diff,x,"hello")
    unit_tests.AssertError(numluau.diff,x,-1)
    unit_tests.AssertError(numluau.diff,x,2)

    unit_tests.AssertError(numluau.diff,"testing123")

    unit_tests.AssertEquals(y:toflatlist(), {1,1,1,1,1,1,1,1,1})

    x = numluau.array({
        {1,2},
        {3,4}
    })

    y = numluau.diff(x,0)

    unit_tests.AssertEquals(y:toflatlist(), {1,2})
    unit_tests.AssertEquals(y.Shape, {2,1})
    unit_tests.AssertEquals(y.Strides, {1,1})

    y = numluau.diff(x,1)

    unit_tests.AssertEquals(y:toflatlist(), {2,2})
    unit_tests.AssertEquals(y.Shape, {1,2})
    unit_tests.AssertEquals(y.Strides, {2,1})
end)

unit_tests.Test("gradient",function()
    local x : numluau.ndArray<number> = numluau.arange(1,10)
    local y : numluau.ndArray<number> = numluau.gradient(x)
    
    unit_tests.AssertError(numluau.gradient,x,"hello")
    unit_tests.AssertError(numluau.gradient,x,1,"bye")
    unit_tests.AssertError(numluau.gradient,x,1,-1)
    unit_tests.AssertError(numluau.gradient,x,1,10)

    unit_tests.AssertError(numluau.gradient,"testing123")

    unit_tests.AssertEquals(y:toflatlist(), {1,1,1,1,1,1,1,1,1,1})

    x = numluau.array({
        {1,2},
        {3,4}
    })

    y = numluau.gradient(x,1,0)

    unit_tests.AssertEquals(y:toflatlist(), {1,1,1,1})
    unit_tests.AssertEquals(y.Shape, {2,2})
    unit_tests.AssertEquals(y.Strides, {2,1})

    y = numluau.gradient(x,1)

    unit_tests.AssertEquals(y:toflatlist(), {2,2,2,2})
    unit_tests.AssertEquals(y.Shape, {2,2})
    unit_tests.AssertEquals(y.Strides, {2,1})

    local A = numluau.arange(1,9):reshape(3,3)
    local B1,B2 = numluau.gradient(A)

    unit_tests.AssertEquals(B1:toflatlist(), {3,3,3,3,3,3,3,3,3})
    unit_tests.AssertEquals(B1.Shape, {3,3})
    unit_tests.AssertEquals(B1.Strides, {3,1})

    unit_tests.AssertEquals(B2:toflatlist(), {1,1,1,1,1,1,1,1,1})
    unit_tests.AssertEquals(B2.Shape, {3,3})
    unit_tests.AssertEquals(B2.Strides, {3,1})
end)


unit_tests.ProcessResults()
