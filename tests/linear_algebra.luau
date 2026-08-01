local unit_tests = require("./unit_test")
local numluau = require("../numluau")

unit_tests.Test("matrix multiplication", function()
	local A = numluau.array({ { 2, 0, 0 }, { 0, 2, 0 } })
	local B = numluau.array({ 1, 2, 3 })

	local C = numluau.linalg.matmul(A, B)

	unit_tests.AssertEquals(C:toflatlist(), { 2, 4 })
	unit_tests.AssertEquals(C.Shape, { 2 })
	unit_tests.AssertEquals(C.Strides, { 1 })

	A = numluau.array({ { 2, 0, 0 }, { 0, 2, 0 } })
	B = numluau.array({ { 1, 0, 0, 0 }, { 0, 1, 0, 0 }, { 0, 1, 0, 0 } })

	C = numluau.linalg.matmul(A, B)
	unit_tests.AssertEquals(C:toflatlist(), { 2, 0, 0, 0, 0, 2, 0, 0 })
	unit_tests.AssertEquals(C.Shape, { 2, 4 })
	unit_tests.AssertEquals(C.Strides, { 4, 1 })

	A = numluau.array({ { 1, 0, 0 }, { 0, 1, 0 }, { 0, 0, 1 } })
	B = numluau.array({ { 1, 2, 3 }, { 1, 2, 3 }, { 1, 2, 3 } })

	C = numluau.linalg.matmul(A, B)
	unit_tests.AssertEquals(C:toflatlist(), { 1, 2, 3, 1, 2, 3, 1, 2, 3 })
	unit_tests.AssertEquals(C.Shape, { 3, 3 })
	unit_tests.AssertEquals(C.Strides, { 3, 1 })

	A = numluau.array({ { 1, 0, 0, 0 } })
	B = numluau.array({ { 1, 2, 3 }, { 1, 2, 3 }, { 1, 2, 3 } })

	unit_tests.AssertError(numluau.linalg.matmul, A, B)

	A = numluau.array({ { 2, 0 }, { 0, 2 } })
	B = numluau.array({ { 1, 0, 0, 0 }, { 0, 1, 0, 0 }, { 0, 1, 0, 0 } })

	unit_tests.AssertError(numluau.linalg.matmul, A, B)
end)

unit_tests.Test("dot", function()
	local A = numluau.array({ { 2, 0, 0 }, { 0, 2, 0 } })
	local B = numluau.array({ 1, 2, 3 })

	unit_tests.AssertError(numluau.linalg.dot, A, B)

	A = numluau.array({ 2, 0, 0 })
	B = numluau.array({ 1, 2, 3, 4, 5 })

	unit_tests.AssertError(numluau.linalg.dot, A, B)

	A = numluau.array({ 2, 0, 0 })
	B = numluau.array({ 1, 2, 3 })
	unit_tests.AssertEquals(numluau.linalg.dot(A, B):item(), 2)
end)

unit_tests.Test("det", function()
	local A = numluau.array({
		{
			{ 1, 0, 0 },
			{ 0, 1, 0 },
			{ 0, 0, 1 },
			{ 2, 0, 0 },
			{ 0, 2, 0 },
			{ 0, 0, 2 },
		},
		{
			{ 3, 0, 0 },
			{ 0, 3, 0 },
			{ 0, 0, 3 },
			{ 4, 0, 0 },
			{ 0, 4, 0 },
			{ 0, 0, 4 },
		},
	})
	unit_tests.AssertError(numluau.linalg.det, A)

	A = numluau.array({ { 2, 0, 0 }, { 0, 2, 0 } })
	unit_tests.AssertError(numluau.linalg.det, A)

	unit_tests.AssertEquals(numluau.linalg.det(numluau.array({ { 2, 0 }, { 0, 2 } })):item(), 4)
	unit_tests.AssertEquals(numluau.linalg.det(numluau.array({ { 4, 6 }, { 3, 8 } })):item(), 14)
	unit_tests.AssertEquals(numluau.linalg.det(numluau.array({ { 1, 2 }, { 2, 4 } })):item(), 0)
	unit_tests.AssertEquals(numluau.linalg.det(numluau.array({ { 1, 5 }, { 3, 2 } })):item(), -13)

	unit_tests.AssertEquals(numluau.linalg.det(numluau.array({ { 1, 0, 0 }, { 0, 1, 0 }, { 0, 0, 1 } })):item(), 1)
	unit_tests.AssertEquals(numluau.linalg.det(numluau.array({ { 6, 1, 1 }, { 4, -2, 5 }, { 2, 8, 7 } })):item(), -306)
	unit_tests.AssertEquals(numluau.linalg.det(numluau.array({ { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 } })):item(), 0)

	unit_tests.AssertAproxEquals(
		numluau.linalg.det(numluau.array({ { 2, 3, 1, 5 }, { 1, 0, 3, 1 }, { 0, 2, -1, 4 }, { 5, 1, 2, 2 } })):item(),
		-40
	)
	unit_tests.AssertAproxEquals(
		numluau.linalg.det(numluau.array({ { 1, 2, 3, 4 }, { 2, 0, 1, 5 }, { 0, -1, 4, 2 }, { 3, 2, 4, 9 } })):item(),
		0
	)
	unit_tests.AssertAproxEquals(
		numluau.linalg.det(numluau.array({ { 2, 5, 7, 9 }, { 0, 3, 6, 1 }, { 0, 0, -1, 4 }, { 0, 0, 0, 5 } })):item(),
		-30
	)
end)

unit_tests.Test("cross", function()
	local A = numluau.array({ { 2, 0, 0 }, { 0, 2, 0 } })
	local B = numluau.array({ { 2, 0, 0 }, { 0, 2, 0 } })

	unit_tests.AssertError(numluau.linalg.cross, A, B)

	A = numluau.array(2)
	B = numluau.array(2)

	unit_tests.AssertError(numluau.linalg.cross, A, B)

	A = numluau.array({ 2, 0, 0 })
	B = numluau.array({ 1, 2, 3, 4, 5 })
	unit_tests.AssertError(numluau.linalg.cross, A, B)

	A = numluau.array({ 2, 0, 0, 0 })
	B = numluau.array({ 1, 2, 3, 4 })
	unit_tests.AssertError(numluau.linalg.cross, A, B)

	A = numluau.array({ 2, 0, 0 })
	B = numluau.array({ 1, 2, 3 })
	local expected = numluau.array({ 0, -6, 4 })
	unit_tests.AssertEquals(numluau.linalg.cross(A, B):toflatlist(), expected:toflatlist())
end)

unit_tests.Test("eigval", function()
	local matrix = numluau.array({ { 1, 0 }, { 0, 1 } })
	local eigen_values = numluau.linalg.eigenval(matrix)

	local eig_sorted = eigen_values:toflatlist()
	table.sort(eig_sorted)

	unit_tests.AssertAproxEquals(eig_sorted, { 1, 1 })

	matrix = numluau.array({ { 125, 0 }, { 0, 255 } })
	eigen_values = numluau.linalg.eigenval(matrix)

	eig_sorted = eigen_values:toflatlist()
	table.sort(eig_sorted)

	unit_tests.AssertAproxEquals(eig_sorted, { 125, 255 })

	matrix = numluau.array({ { 1, 3, 2 }, { 2, 2, 1 }, { 3, 1, 3 } })
	eigen_values = numluau.linalg.eigenval(matrix)

	eig_sorted = eigen_values:toflatlist()
	table.sort(eig_sorted)

	unit_tests.AssertAproxEquals(eig_sorted, { -math.sqrt(2), math.sqrt(2), 6 })

	matrix = numluau.array({ { 3, 0, 0 }, { 0, -5, 0 }, { 0, 0, 2 } })
	eigen_values = numluau.linalg.eigenval(matrix)

	eig_sorted = eigen_values:toflatlist()
	table.sort(eig_sorted)

	local determinant = numluau.linalg.det(matrix)

	local eig_prod = 1
	for i = 1, #eig_sorted do
		eig_prod *= eig_sorted[i]
	end

	unit_tests.AssertAproxEquals(determinant:item(), eig_prod)

	unit_tests.AssertAproxEquals(eig_sorted, { -5, 2, 3 })

	unit_tests.AssertError(numluau.linalg.eigenval, numluau.array({ { 1, 2 }, { 3, 4 }, { 5, 6 } }))
	unit_tests.AssertError(numluau.linalg.eigenval, numluau.array({ 1, 2, 3, 4, 5, 6 }))
	unit_tests.AssertError(numluau.linalg.eigenval, numluau.array({ { { 1, 2, 3 } } }))
end)

unit_tests.Test("eig", function()
	local matrix = numluau.array({ { 1, 0 }, { 0, 1 } })
	local eigen_values, eigen_vectors = numluau.linalg.eig(matrix)

	unit_tests.AssertEquals(eigen_values:toflatlist(), { 1, 1 })
	unit_tests.AssertEquals(eigen_vectors:toflatlist(), { 1, 1, 0, 0 })

	matrix = numluau.array({ { 3, 0, 0 }, { 0, -5, 0 }, { 0, 0, 2 } })
	eigen_values, eigen_vectors = numluau.linalg.eig(matrix)

	local eig_sorted = eigen_values:toflatlist()
	table.sort(eig_sorted)

	local determinant = numluau.linalg.det(matrix)

	local eig_prod = 1
	for i = 1, #eig_sorted do
		eig_prod *= eig_sorted[i]
	end

	unit_tests.AssertAproxEquals(determinant:item(), eig_prod)

	unit_tests.AssertAproxEquals(eig_sorted, { -5, 2, 3 })
	unit_tests.AssertAproxEquals(eigen_vectors:toflatlist(), { 1, 0, 0, 0, -1, 0, 0, 0, 1 })

	matrix = numluau.array({ { 1, 3, 2 }, { 2, 2, 1 }, { 3, 1, 3 } })
	eigen_values, eigen_vectors = numluau.linalg.eig(matrix)

	eig_sorted = eigen_values:toflatlist()
	table.sort(eig_sorted)

	unit_tests.AssertAproxEquals(eig_sorted, { -math.sqrt(2), math.sqrt(2), 6 })
	unit_tests.AssertAproxEquals(eigen_vectors:toflatlist(), {
		0.55138017782879,
		-0.81251992006875,
		-0.23258781949447,

		0.45112923640538,
		0.33655677059078,
		-0.56151666826634,

		0.70175658996392,
		0.47596314947797,
		0.79410448776082,
	})
end)

unit_tests.Test("qr", function()
	local matrix = numluau.array({ { 12, -51 }, { 6, 167 } })
	local Q, R = numluau.linalg.qr(matrix)

	unit_tests.AssertEquals(Q.Shape, { 2, 2 })
	unit_tests.AssertEquals(R.Shape, { 2, 2 })

	unit_tests.AssertAproxEquals(R[2][1], 0)

	matrix = numluau.array({ { 1, 2, 3 }, { 3, 2, 1 }, { 2, 1, 3 } })
	Q, R = numluau.linalg.qr(matrix)

	unit_tests.AssertAproxEquals(R:toflatlist(), {
		math.sqrt(14),
		5 * math.sqrt(2 / 7),
		6 * math.sqrt(2 / 7),

		0,
		math.sqrt(13 / 7),
		17 / math.sqrt(91),

		0,
		0,
		6 * math.sqrt(2 / 13),
	})

	unit_tests.AssertAproxEquals(Q:toflatlist(), {
		1 / math.sqrt(14),
		9 / math.sqrt(91),
		1 / math.sqrt(26),

		3 / math.sqrt(14),
		-1 / math.sqrt(91),
		-3 / math.sqrt(26),

		math.sqrt(2 / 7),
		-3 / math.sqrt(91),
		2 * math.sqrt(2 / 13),
	})
	--unit_tests.AssertEquals(R:toflatlist(), { 2, 2 })
end)

unit_tests.Test("lu", function()
	local matrix = numluau.array({ { 1, 2 }, { 3, 4 } })
	local L, U, _, swaps = numluau.linalg.lu(matrix)

	unit_tests.AssertTrue(L ~= nil)
	unit_tests.AssertEquals(L.Shape, { 2, 2 })
	unit_tests.AssertEquals(U.Shape, { 2, 2 })
	unit_tests.AssertEquals(swaps, 1)
end)

unit_tests.Test("solve", function()
	local A = numluau.array({ { 1, 2 }, { 3, 4 } })
	local B = numluau.array({ 5, 11 })

	local X = numluau.linalg.solve(A, B)

	unit_tests.AssertEquals(X.Shape, { 2 })
	unit_tests.AssertAproxEquals(X[1], 1)
	unit_tests.AssertAproxEquals(X[2], 2)
	A = numluau.array({ { 1, 1, -1 }, { 1, -2, 3 }, { 2, 3, 1 } })
	B = numluau.array({ 4, -6, 7 })

	X = numluau.linalg.solve(A, B)
	unit_tests.AssertAproxEquals(X:toflatlist(), { 1, 2, -1 })
end)

unit_tests.Test("svd", function()
	local A = numluau.array({ { 1, 0 }, { 0, 1 } })
	local U, sigma, Vt = numluau.linalg.svd(A)

	unit_tests.AssertEquals(U.Shape, { 2, 2 })
	unit_tests.AssertEquals(Vt.Shape, { 2, 2 })
	unit_tests.AssertEquals(sigma.Shape, { 2 })

	unit_tests.AssertAproxEquals(sigma[1], 1)
	unit_tests.AssertAproxEquals(sigma[2], 1)

	A = numluau.array({ { 3, 2 }, { 2, 3 }, { 2, -2 } })
	U, sigma, Vt = numluau.linalg.svd(A)

    --stylua: ignore
	unit_tests.AssertAproxEquals(Vt:toflatlist(), {
		1 / math.sqrt(2), -1 / math.sqrt(2),
		1 / math.sqrt(2), 1 / math.sqrt(2),
	})

	--stylua: ignore
	unit_tests.AssertAproxEquals(U:toflatlist(), {
	    -1 / math.sqrt(2), -1 / math.sqrt(18), -2/3,
	    -1 / math.sqrt(2), 1 / math.sqrt(18), 2/3,
	    0, -4 / math.sqrt(18), 1/3,
	})

	unit_tests.AssertAproxEquals(sigma:toflatlist(), { 5, 3 })
end)

unit_tests.Test("lstsq", function()
	local x = numluau.arange(-1, 20)
	local y = x * 2

	local coef = numluau.linalg.lstsq(x, y, 1)
	print(coef)

	unit_tests.AssertEquals(coef.Shape, { 2 })
	unit_tests.AssertAproxEquals(coef:toflatlist(), { 1.2313086118830172, 3.7001619337059184 })
end)

unit_tests.Test("norm", function()
	local x = numluau.array({ 3, 4 })
	unit_tests.AssertEquals(numluau.linalg.norm(x):item(), 5)

	x = numluau.array({ 0, 5 })
	unit_tests.AssertEquals(numluau.linalg.norm(x):item(), 5)

	x = numluau.array({ 1, 2, 2 })
	unit_tests.AssertEquals(numluau.linalg.norm(x):item(), 3)

	x = numluau.array({ 1, -2, -5 })
	unit_tests.AssertEquals(numluau.linalg.norm(x, 0, 1):item(), 8)

	x = numluau.array({ { -3, 4, 0 }, { 1, -2, -5 }, { 0, 0, 2 } })
	unit_tests.AssertEquals(numluau.linalg.norm(x, 0, 1):toflatlist(), { 7, 8, 2 })
	unit_tests.AssertEquals(numluau.linalg.norm(x, 1, 1):toflatlist(), { 4, 6, 7 })

	unit_tests.AssertEquals(numluau.linalg.norm(x, 0, 2):toflatlist(), { 5, math.sqrt(30), 2 })
	unit_tests.AssertEquals(numluau.linalg.norm(x, 1, 2):toflatlist(), { math.sqrt(10), math.sqrt(20), math.sqrt(29) })
end)

unit_tests.ProcessResults()
