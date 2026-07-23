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

unit_tests.Test("dot",function()
    local A = numluau.array({{2,0,0},{0,2,0}})
    local B = numluau.array({1,2,3})

    unit_tests.AssertError(numluau.linalg.dot,A, B)

    A = numluau.array({2,0,0})
    B = numluau.array({1,2,3,4,5})

    unit_tests.AssertError(numluau.linalg.dot,A, B)

    A = numluau.array({2,0,0})
    B = numluau.array({1,2,3})
    unit_tests.AssertEquals(numluau.linalg.dot(A, B):item(),2)


end)

unit_tests.Test("det",function()
    local A = numluau.array({{
        {1,0,0},{0,1,0},{0,0,1},
        {2,0,0},{0,2,0},{0,0,2},
    },{
        {3,0,0},{0,3,0},{0,0,3},
        {4,0,0},{0,4,0},{0,0,4},
    }})
    unit_tests.AssertError(numluau.linalg.det,A)

    A = numluau.array({{2,0,0},{0,2,0}})
    unit_tests.AssertError(numluau.linalg.det,A)

    unit_tests.AssertEquals(numluau.linalg.det(numluau.array({{2,0},{0,2}})):item(),4)
    unit_tests.AssertEquals(numluau.linalg.det(numluau.array({{4,6},{3,8}})):item(),14)
    unit_tests.AssertEquals(numluau.linalg.det(numluau.array({{1,2},{2,4}})):item(),0)
    unit_tests.AssertEquals(numluau.linalg.det(numluau.array({{1,5},{3,2}})):item(),-13)

    unit_tests.AssertEquals(numluau.linalg.det(numluau.array({{1,0,0},{0,1,0},{0,0,1}})):item(),1)
    unit_tests.AssertEquals(numluau.linalg.det(numluau.array({{6,1,1},{4,-2,5},{2,8,7}})):item(),-306)
    unit_tests.AssertEquals(numluau.linalg.det(numluau.array({{0,0,0},{0,0,0},{0,0,0}})):item(),0)

    unit_tests.AssertAproxEquals(numluau.linalg.det(numluau.array({{2,3,1,5},{1,0,3,1},{0,2,-1,4},{5,1,2,2}})):item(),-40)
    unit_tests.AssertAproxEquals(numluau.linalg.det(numluau.array({{1,2,3,4},{2,0,1,5},{0,-1,4,2},{3,2,4,9}})):item(),0) 
    unit_tests.AssertAproxEquals(numluau.linalg.det(numluau.array({{2,5,7,9},{0,3,6,1},{0,0,-1,4},{0,0,0,5}})):item(),-30) 


end)

unit_tests.Test("cross",function()
    local A = numluau.array({{2,0,0},{0,2,0}})
    local B = numluau.array({{2,0,0},{0,2,0}})

    unit_tests.AssertError(numluau.linalg.cross,A,B)

    A = numluau.array(2)
    B = numluau.array(2)

    unit_tests.AssertError(numluau.linalg.cross,A,B)

    A = numluau.array({2,0,0})
    B = numluau.array({1,2,3,4,5})
    unit_tests.AssertError(numluau.linalg.cross,A,B)

    A = numluau.array({2,0,0,0})
    B = numluau.array({1,2,3,4})
    unit_tests.AssertError(numluau.linalg.cross,A,B)

    A = numluau.array({2,0,0})
    B = numluau.array({1,2,3})
    local expected = numluau.array({0,-6,4})
    unit_tests.AssertEquals(numluau.linalg.cross(A,B):toflatlist(),expected:toflatlist())
end)

-- vibecoded this test because of complexity, rest of the tests are human written
unit_tests.Test("eigenvalues and eigenvectors", function()
    local matrix = numluau.array({{1, 0}, {0, 2}})
    local ev = numluau.linalg.eigenval(matrix)
    
    unit_tests.AssertTrue(
        (math.abs(ev:toflatlist()[1] - 2) < 1e-9 and math.abs(ev:toflatlist()[2] - 1) < 1e-9) or
        (math.abs(ev:toflatlist()[1] - 1) < 1e-9 and math.abs(ev:toflatlist()[2] - 2) < 1e-9)
    )

    local eigenvalues, eigenvectors = numluau.linalg.eig(matrix)
    unit_tests.AssertEquals(eigenvalues.Shape, {2})
    unit_tests.AssertEquals(eigenvectors.Shape, {2, 2})
end)

unit_tests.Test("qr",function()
    local matrix = numluau.array({{12,-51},{6,167}})
    local Q,R = numluau.linalg.qr(matrix)

    unit_tests.AssertEquals(Q.Shape, {2,2})
    unit_tests.AssertEquals(R.Shape, {2,2})

    unit_tests.AssertAproxEquals(R[2][1], 0)
end)

unit_tests.Test("lu",function()
    local matrix = numluau.array({{1,2},{3,4}})
    local L,U,_,swaps = numluau.linalg.lu(matrix)

    unit_tests.AssertTrue(L ~= nil)
    unit_tests.AssertEquals(L.Shape, {2,2})
    unit_tests.AssertEquals(U.Shape, {2,2})
    unit_tests.AssertEquals(swaps, 1)
end)

unit_tests.Test("solve",function()
    local A = numluau.array({{1, 2}, {3, 4}})
    local B = numluau.array({5, 11})

    local X = numluau.linalg.solve(A,B)

    unit_tests.AssertEquals(X.Shape,{2})
    unit_tests.AssertAproxEquals(X[1],1)
    unit_tests.AssertAproxEquals(X[2],2)
end)

unit_tests.Test("svd",function()
    local A = numluau.array({{1, 0}, {0, 1}})
    local U, sigma, Vt = numluau.linalg.svd(A)

    unit_tests.AssertEquals(U.Shape,{2,2})
    unit_tests.AssertEquals(Vt.Shape,{2,2})
    unit_tests.AssertEquals(sigma.Shape,{2})

    unit_tests.AssertAproxEquals(sigma[1],1)
    unit_tests.AssertAproxEquals(sigma[2],1)

end)

unit_tests.Test("lstsq",function()
    local x = numluau.array({1,2,3})
    local y = numluau.array({2,4,6})

    local coef = numluau.linalg.lstsq(x, y,1)
    unit_tests.AssertEquals(coef.Shape, {2})

end)

unit_tests.ProcessResults()
