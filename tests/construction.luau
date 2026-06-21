local unit_tests = require("./unit_test")
local numluau = require("../numluau/numluau")

unit_tests.Test("wrap luau table into a ndarray",function()
    local A : numluau.ndArray<number> = numluau.array({1,2,3})

    unit_tests.AssertEquals(A.Shape, {3})
    unit_tests.AssertEquals(A.Strides, {1})
    unit_tests.AssertEquals(A.ndim, 1)
    unit_tests.AssertEquals(A.Buffer, {1,2,3})
end)

unit_tests.Test("0D ndarray creation", function()
    local A : numluau.ndArray<number> = numluau.array(0)

    unit_tests.AssertEquals(A.Buffer, {0})
    unit_tests.AssertEquals(A.Strides, {})
    unit_tests.AssertEquals(A.Shape, {})
    unit_tests.AssertEquals(A.ndim, 0)
end)

unit_tests.Test("arrange ndarray construction", function()
    local A = numluau.arange(1,10)
    unit_tests.AssertEquals(A.Buffer, {1,2,3,4,5,6,7,8,9,10})
end)

unit_tests.Test("masked ndarray construction", function()
    local A = numluau.array({true,true,true,false})
    local B = numluau.array({1,2,3,4})
    local fill_value = 255

    local masked = numluau.where(A, B,fill_value)

    unit_tests.AssertEquals(masked.Buffer,{1,2,3,255})
end)

unit_tests.Test("masked ndarray construction", function()
    local A = numluau.array({true,true,true,false})
    local B = numluau.array({1,2,3,4})
    local fill_value = 255

    local masked = numluau.where(A, B,fill_value)

    unit_tests.AssertEquals(masked.Buffer,{1,2,3,255})
end)

unit_tests.Test("ones construction",function()
    local A = numluau.ones(5)
    local B = numluau.array({1,1,1,1,1})

    unit_tests.AssertEquals(A.Buffer, B.Buffer)

    A = numluau.ones(2,2)
    B = numluau.array({{1,1},{1,1}})

    unit_tests.AssertEquals(A.Buffer, B.Buffer)

    A = numluau.ones()
    B = numluau.array({1})

    unit_tests.AssertEquals(A.Buffer, B.Buffer)
    unit_tests.AssertEquals(A.ndim, 0)
end)

unit_tests.Test("zeroes construction",function()
    local A = numluau.zeros(5)
    local B = numluau.array({0,0,0,0,0})

    unit_tests.AssertEquals(A.Buffer, B.Buffer)

    A = numluau.zeros()
    B = numluau.array({0})

    unit_tests.AssertEquals(A.Buffer, B.Buffer)
    unit_tests.AssertEquals(A.ndim, 0)
end)

unit_tests.Test("ndarray reshaping",function()
    local A = numluau.arange(1,4)
    A = numluau.reshape(A, {2,2})

    unit_tests.AssertEquals(A.Shape, {2,2})
    unit_tests.AssertEquals(A.Strides, {2,1})

    local result = pcall(numluau.reshape,A, {10})
    unit_tests.AssertFalse(result)
end)

unit_tests.Test("meshgrid generation", function()
    local X = numluau.array({1,2,3})
    local Y = numluau.array({4,5})

    local XV,YV = numluau.meshgrid(X,Y)

    unit_tests.AssertEquals(XV.Shape, {2,3})
    unit_tests.AssertEquals(YV.Shape, {2,3})

    unit_tests.AssertEquals(XV.Buffer, {1,2,3,1,2,3})
    unit_tests.AssertEquals(YV.Buffer, {4,4,4,5,5,5})

    local grid = numluau.reshape(X, {3,1})
    local result = pcall(numluau.meshgrid,grid, Y)
    unit_tests.AssertFalse(result)
end)


unit_tests.PrintResults()