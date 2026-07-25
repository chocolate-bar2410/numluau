--!native
local module = {}
local types = require("../types")
local ndArray_utils = require("../utility/ndarray")

local exceptions = require("../Exceptions")
local ndarray = require("../ndarray/ndarray")

local constructors = require("../ndarray/constructors")

local abs = math.abs
local sqrt = math.sqrt

--- the linear algebra submodule for numluau.
---@class linalg

export type interface = {
	matmul: (A: types.ndArray<number>, B: types.ndArray<number>) -> types.ndArray<number>,
	dot: (A: types.ndArray<number>, B: types.ndArray<number>) -> types.ndArray<number>,
	det: (matrix: types.ndArray<number>) -> types.ndArray<number>,
	cross: (A: types.ndArray<number>, B: types.ndArray<number>) -> types.ndArray<number>,
	eigenval: (matrix: types.ndArray<number>) -> types.ndArray<number>,
	eig: (matrix: types.ndArray<number>) -> (types.ndArray<number>, types.ndArray<number>),
	qr: (matrix: types.ndArray<number>) -> (types.ndArray<number>, types.ndArray<number>),
	lu: (matrix: types.ndArray<number>) -> (types.ndArray<number>, types.ndArray<number>, { number }, number),
	solve: (A: types.ndArray<number>, B: types.ndArray<number>) -> types.ndArray<number>,
	norm: (matrix: types.ndArray<number>, axis: number, order: number) -> types.ndArray<number>,
	svd: (A: types.ndArray<number>) -> (types.ndArray<number>, types.ndArray<number>, types.ndArray<number>),
	lstsq: (x: types.ndArray<number>, y: types.ndArray<number>, degree: number) -> types.ndArray<number>,
}

--- returns the result of a matrix multiplication between A and B
--- if A is ndim = 2 and B is ndim = 1 then a matrix-vector multiplication is done instead.
---@within linalg
---@method matmul
---@param A ndArray
---@param B ndArray
---@return ndArray
module.matmul = function(A: types.ndArray<number>, B: types.ndArray<number>)
	if A.ndim == 2 and B.ndim == 1 then
		local A_width: number = A.Shape[1]
		local A_height: number = A.Shape[2]

		local B_len: number = B.Shape[1]

		if B_len ~= A_height then
			exceptions.FormatException(
				"Value",
				"matrix vector multiplication requires vector length = matrix column length"
			)
		end

		local Shape: { number } = { A_width }
		local Strides: { number } = ndArray_utils.ComputeStrides(Shape)

		local result: types.ndArray<number> = ndarray(table.create(A_width, 0), Shape, Strides, 0, A.dtype)

		for i = 1, A_width do
			local row_A: types.ndArray<number> = A[i]
			for j = 1, A_height do
				result[i] += row_A[j] * B[j]
			end
		end

		return result
	end

	if A.ndim ~= 2 or B.ndim ~= 2 then
		exceptions.FormatException("Value", "matrix multiplication needs A.ndim = B.ndim")
	end

	local A_width: number = A.Shape[1]
	local A_height: number = A.Shape[2]

	local B_width: number = B.Shape[1]
	local B_height: number = B.Shape[2]

	if A_height ~= B_width then
		exceptions.FormatException("Value", "matrix multiplication needs A's column length = B's row length")
	end

	local Shape: { number } = { A_width, B_height }
	local Strides: { number } = ndArray_utils.ComputeStrides(Shape)

	local result: types.ndArray<number> = ndarray(table.create(A_width * B_height, 0), Shape, Strides, 0, A.dtype)

	-- apparently tranposing B improves cache locality
	local Bt: types.ndArray<number> = B:transpose()

	for i = 1, A_width do
		local row_A: types.ndArray<number> = A[i]

		for j = 1, B_height do
			local row_Bt: types.ndArray<number> = Bt[j]
			local sum: number = 0
			for k = 1, B_width do
				sum += row_A[k] * row_Bt[k]
			end

			result[i][j] = sum
		end
	end

	return result
end

--- preforms a LU decomposition on the matrix, producing values:
--- - lower triangular ndArray (L).
--- - upper triangular ndArray (U).
--- - permutation table.
--- - swap count.
--- given matrix = LU
---@within linalg
---@method lu
---@param matrix ndArray
---@return (ndArray, ndArray, {number}, number)
module.lu = function(matrix: types.ndArray<number>)
	local n = matrix.Shape[1]
	local U = matrix:copy()

	local L_data = ndArray_utils.IdentityBuffer(n)
	local L = ndarray(L_data, { n, n }, { n, 1 }, 0, matrix.dtype)

	local P = {}
	for i = 1, n do
		P[i] = i
	end

	local swaps = 0

	for k = 1, n do
		local pivot_row = k
		local max_value = abs(U[k][k])
		for i = k + 1, n do
			local value = abs(U[i][k])
			if value <= max_value then continue end
			max_value = value
			pivot_row = i
		end

		if max_value < 1e-9 then return nil, nil, nil, swaps end

		if pivot_row ~= k then
			for j = 1, n do
				U[k][j], U[pivot_row][j] = U[pivot_row][j], U[k][j]
			end

			for j = 1, k - 1 do
				L[k][j], L[pivot_row][j] = L[pivot_row][j], L[k][j]
			end

			P[k], P[pivot_row] = P[pivot_row], P[k]

			swaps += 1
		end

		local pivot = U[k][k]
		for i = k + 1, n do
			local factor = U[i][k] / pivot
			L[i][k] = factor

			for j = k, n do
				U[i][j] = U[i][j] - factor * U[k][j]
			end
		end
	end

	return L, U, P, swaps
end

--- returns the determinant of the matrix.
---@within linalg
---@method det
---@param matrix ndArray
---@return ndArray
module.det = function(matrix: types.ndArray<number>)
	if matrix.ndim ~= 2 then exceptions.FormatException("LinAlg", "determinant is only support for ndim = 2") end

	if matrix.Shape[1] ~= matrix.Shape[2] then
		exceptions.FormatException("LinAlg", "determinant only works for square matrices")
	end

	if matrix.Shape[1] == 2 then
		return ndarray({ matrix[1][1] * matrix[2][2] - matrix[1][2] * matrix[2][1] }, {}, {}, 0, matrix.dtype)
	end

	if matrix.Shape[1] == 3 then
		-- optimisation using sarrus's rule
		local aei = matrix[1][1] * matrix[2][2] * matrix[3][3]
		local bfg = matrix[2][1] * matrix[3][2] * matrix[1][3]
		local cdh = matrix[3][1] * matrix[1][2] * matrix[2][3]

		local gec = matrix[1][3] * matrix[2][2] * matrix[3][1]
		local hfa = matrix[2][3] * matrix[3][2] * matrix[1][1]
		local idb = matrix[3][3] * matrix[1][2] * matrix[2][1]

		return ndarray({ (aei + bfg + cdh) - (gec + hfa + idb) }, {}, {}, 0, matrix.dtype)
	end

	-- LU decomposition
	local n = matrix.Shape[1]

	local _, U, _, swaps = module.lu(matrix)

	if not U then return ndarray({ 0 }, {}, {}, 0, matrix.dtype) end

	local result = swaps % 2 == 0 and 1 or -1

	for i = 1, n do
		result *= U[i][i]
	end

	return ndarray({ result }, {}, {}, 0, matrix.dtype)
end

--- returns the dot product between A and B.
---@within linalg
---@method dot
---@param A ndArray
---@param B ndArray
---@return ndArray
module.dot = function(A: types.ndArray<number>, B: types.ndArray<number>)
	if A.ndim == 2 and B.ndim == 2 then
		exceptions.FormatWarn(
			"LinAlg",
			"for 2d ndArrays, its better to use numluau.linalg.matmul instead of numluau.linalg.dot"
		)
		return module.matmul(A, B)
	elseif A.ndim == 0 and B.ndim == 0 then
		exceptions.FormatWarn(
			"LinAlg",
			"for 0d ndArrays, its better to use the * operator instead of numluau.linalg.dot"
		)
		return A * B
	end

	if A.ndim ~= 1 or B.ndim ~= 1 then
		exceptions.FormatException("LinAlg", "both ndims must equal 1 for dot products")
	end

	if #A ~= #B then
		exceptions.FormatException("LinAlg", "both ndArrays must have the same size when doing dot product")
	end

	local result = 0

	local A_data = A:toflatlist()
	local B_data = B:toflatlist()

	for i = 1, #A do
		result += A_data[i] * B_data[i]
	end

	return ndarray(result, {}, {}, 0, A.dtype)
end

--- returns the cross product between A and B
---@within linalg
---@method cross
---@param A ndArray
---@param B ndArray
---@return ndArray
module.cross = function(A: types.ndArray<number>, B: types.ndArray<number>)
	if A.ndim > 1 or B.ndim > 1 then
		exceptions.FormatException("LinAlg", "cross product not implemented for ndim > 1")
	elseif A.ndim < 1 or B.ndim < 1 then
		exceptions.FormatException("LinAlg", "cross product not implemented for ndim < 1")
	elseif A.ndim == 0 or B.ndim == 0 then
		exceptions.FormatException("LinAlg", "cross product undefined for 0d ndArrays")
	end

	if #A ~= #B then
		exceptions.FormatException("LinAlg", "cross product can only be done with ndArrays of the same size")
	end
	if #A ~= 3 then exceptions.FormatException("LinAlg", "cross product only available between 3d vectors") end

	return ndarray({
		A[2] * B[3] - A[3] * B[2],
		A[3] * B[1] - A[1] * B[3],
		A[1] * B[2] - A[2] * B[1],
	}, { 3 }, { 1 }, 0, A.dtype)
end

local function safe_col_dot(matrix: types.ndArray<number>, column_index: number, start_row: number)
	local sum = 0
	local n = matrix.Shape[1]

	for i = start_row, n do
		local val = matrix[i][column_index]
		sum += val * val
	end

	return sum
end

--- Performs a QR decomposition on the matrix, returning a orthogonal matrix Q and a upper triangular matrix R.
---@within linalg
---@method qr
---@param matrix ndArray
---@return (ndArray,ndArray)
module.qr = function(matrix: types.ndArray<number>)
	local n: number = matrix.Shape[1]
	local Q: types.ndArray<number> = matrix:eye()
	local R: types.ndArray<number> = matrix:copy()

	for k = 1, n - 1 do
		local dot_xx = safe_col_dot(R, k, k)
		local alpha = sqrt(dot_xx)

		if R[k][k] < 0 then
			alpha *= -1
		end

		local raw_v = {}
		local v_len = n - k + 1

		raw_v[1] = R[k][k] - alpha

		local v_sum2 = raw_v[1] ^ 2

		for i = 2, v_len do
			raw_v[i] = R[k + i - 1][k]
			v_sum2 += R[k + i - 1][k] ^ 2
		end

		local v_norm = sqrt(v_sum2)

		if v_norm ~= 0 then
			for i = 1, #raw_v do
				raw_v[i] /= v_norm
			end
		end

		for j = k, n do
			local dot = 0
			for i = k, n do
				dot += raw_v[i - k + 1] * R[i][j]
			end

			for i = k, n do
				R[i][j] -= 2 * raw_v[i - k + 1] * dot
			end
		end

		for i = 1, n do
			local dot = 0
			for j = k, n do
				dot += Q[i][j] * raw_v[j - k + 1]
			end

			for j = k, n do
				Q[i][j] -= 2 * dot * raw_v[j - k + 1]
			end
		end
	end

	return Q, R
end

--- Returns the eigen values of the matrix.
---@within linalg
---@method eigenval
---@param matrix ndArray
---@return ndArray
module.eigenval = function(matrix: types.ndArray<number>)
	if matrix.ndim ~= 2 then exceptions.FormatException("LinAlg", "eigenval is only support for ndim = 2") end

	if matrix.Shape[1] ~= matrix.Shape[2] then
		exceptions.FormatException("LinAlg", "non square matrices dont have eigenvalues")
	end

	if matrix.Shape[1] == 2 then
		local mean = (matrix[1][1] + matrix[2][2]) / 2
		local determinant = matrix[1][1] * matrix[2][2] - matrix[1][2] * matrix[2][1]

		local v1 = mean + sqrt(mean * mean - determinant)
		local v2 = mean - sqrt(mean * mean - determinant)

		return ndarray({ v1, v2 }, { 2 }, { 1 }, 0, matrix.dtype)
	end

	-- QR decomposition
	local n: number = matrix.Shape[1]
	local Ak = matrix:copy()
	local Q: types.ndArray<number>
	local R: types.ndArray<number>

	local tolerance = 1e-12

	local max_iterations = 200
	local iterations = 0

	repeat
		Q, R = module.qr(Ak)
		Ak = module.matmul(R, Q)

		local maximum = -math.huge
		for i = 2, matrix.Shape[2] do
			local Ak_row = Ak[i]
			for k = 1, i - 1 do
				maximum = math.max(abs(Ak_row[k]), maximum)
			end
		end
		iterations += 1
	until maximum < tolerance or iterations >= max_iterations

	local result = {}
	for i = 1, n do
		table.insert(result, Ak[i][i])
	end

	return ndarray(result, { n }, { 1 }, 0, matrix.dtype)
end

--- returns the eigen values and eigen vectors of the matrix
--- the eigen vectors being given as a single 2d ndArray in column major order.
---@within linalg
---@method eig
---@param matrix ndArray
---@return (ndArray,ndArray)
module.eig = function(matrix: types.ndArray<number>)
	if matrix.ndim ~= 2 then exceptions.FormatException("LinAlg", "eigenval is only support for ndim = 2") end

	if matrix.Shape[1] ~= matrix.Shape[2] then
		exceptions.FormatException("LinAlg", "non square matrices dont have eigenvalues")
	end

	if matrix.Shape[1] == 2 then
		local mean = (matrix[1][1] + matrix[2][2]) / 2
		local determinant = matrix[1][1] * matrix[2][2] - matrix[1][2] * matrix[2][1]

		local v1 = mean + sqrt(mean * mean - determinant)
		local v2 = mean - sqrt(mean * mean - determinant)

		local fuzzy_factor = 1e-12

		local ev1_x = if abs(matrix[1][2]) > fuzzy_factor
			then 1
			elseif abs(matrix[2][1]) > fuzzy_factor then -(matrix[2][2] - v1) / matrix[2][1]
			else 1
		local ev1_y = if abs(matrix[1][2]) > fuzzy_factor
			then -(matrix[1][1] - v1) / matrix[1][2]
			elseif abs(matrix[2][1]) > fuzzy_factor then 1
			else 0

		local ev2_x = if abs(matrix[1][2]) > fuzzy_factor
			then 1
			elseif abs(matrix[2][1]) > fuzzy_factor then -(matrix[2][2] - v2) / matrix[2][1]
			else 1
		local ev2_y = if abs(matrix[1][2]) > fuzzy_factor
			then -(matrix[1][1] - v2) / matrix[1][2]
			elseif abs(matrix[2][1]) > fuzzy_factor then 1
			else 0

		local ev1_length = sqrt(ev1_x ^ 2 + ev1_y ^ 2)
		local ev2_length = sqrt(ev2_x ^ 2 + ev2_y ^ 2)

		ev1_x /= ev1_length
		ev1_y /= ev1_length

		ev2_x /= ev2_length
		ev2_y /= ev2_length

		return ndarray({ v1, v2 }, { 2 }, { 1 }, 0, matrix.dtype),
			ndarray({ ev1_x, ev2_x, ev1_y, ev2_y }, { 2, 2 }, { 2, 1 }, 0, matrix.dtype)
	end

	-- QR decomposition
	local n: number = matrix.Shape[1]
	local Ak = matrix:copy()
	local Q: types.ndArray<number>, R: types.ndArray<number> = module.qr(Ak)

	local eigen_vectors = Q
	local tolerance = 1e-12

	local max_iterations = 200
	local iterations = 0

	repeat
		Q, R = module.qr(Ak)
		Ak = module.matmul(R, Q)

		eigen_vectors = module.matmul(eigen_vectors, Q)

		local maximum = -math.huge

		for i = 2, matrix.Shape[2] do
			local Ak_row = Ak[i]
			for k = 1, i - 1 do
				maximum = math.max(abs(Ak_row[k]), maximum)
			end
		end

		iterations += 1

	until maximum < tolerance or iterations >= max_iterations

	local result = {}
	for i = 1, n do
		table.insert(result, Ak[i][i])
	end

	return ndarray(result, { n }, { 1 }, 0, matrix.dtype), eigen_vectors
end

--- returns the solution to the equation $Ax = B$
---@within linalg
---@method solve
---@param A ndArray
---@param B ndArray
---@return ndArray
module.solve = function(A: types.ndArray<number>, B: types.ndArray<number>)
	if A.ndim ~= 2 then exceptions.FormatException("LinAlg", "coefficient matrix must be ndim = 2") end

	if B.ndim ~= 1 then exceptions.FormatException("LinAlg", "ordinate ndarray must be ndim = 1") end

	if A.Shape[1] ~= A.Shape[2] then
		exceptions.FormatException("LinAlg", "coefficient matrix must be a square matrix")
	end

	-- solving the equation Ax = B
	-- where A = LU
	local L, U, P = module.lu(A)
	local n = A.Shape[1]
	if not L then exceptions.FormatException("LinAlg", "A has no inverse") end

	local Y = table.create(n, 0)
	local X_data = table.create(n, 0)

	-- forwards sub to solve LY = B
	for i = 1, n do
		local permuted_row = P[i]
		local b_value = B[permuted_row]
		local sum = 0

		for j = 1, i - 1 do
			sum += L[i][j] * Y[j]
		end

		Y[i] = b_value - sum
	end

	-- backwards sub to solve UX = Y
	for i = n, 1, -1 do
		local sum = 0
		for j = i + 1, n do
			sum += U[i][j] * X_data[j]
		end

		X_data[i] = (Y[i] - sum) / U[i][i]
	end

	return ndarray(X_data, { n }, { 1 }, 0, A.dtype)
end

--- Normalises a matrix across a axis
--- order = 1 does a manhattan normalisation
--- order = 2 does a euclidean normalisation
--- order defaults to 2
--- axis defaults to 0
---@within linalg
---@method norm
---@param matrix ndArray
---@param axis ndArray
---@param order ndArray
---@return ndArray
module.norm = function(matrix: types.ndArray<number>, axis: number, order: number)
	order = order or 2
	axis = axis or 0

	if order == 1 then
		local target_axis = matrix.ndim - axis
		local axis_stride = matrix.Strides[target_axis]
		local axis_shape = matrix.Shape[target_axis]

		local data = {}

		ndArray_utils.ForEachSlice(matrix.Shape, matrix.Strides, axis, matrix.Offset, function(base: number)
			local sum_of_abs = 0

			for i = 0, axis_shape - 1 do
				local index = base + (i * axis_stride)
				sum_of_abs += abs(matrix.Buffer[index + 1])
			end

			if sum_of_abs == 0 then return end

			local length = sqrt(sum_of_abs)

			table.insert(data, length)
		end)

		return ndarray(data, { #data }, { 1 }, 0, "number")
	end

	if order == 2 then
		local target_axis = matrix.ndim - axis
		local axis_stride = matrix.Strides[target_axis]
		local axis_shape = matrix.Shape[target_axis]

		local data = {}

		ndArray_utils.ForEachSlice(matrix.Shape, matrix.Strides, axis, matrix.Offset, function(base: number)
			local sum_of_squares = 0

			for i = 0, axis_shape - 1 do
				local index = base + (i * axis_stride)
				sum_of_squares += matrix.Buffer[index + 1] * matrix.Buffer[index + 1]
			end

			if sum_of_squares == 0 then return end

			local length = sqrt(sum_of_squares)

			table.insert(data, length)
		end)

		return ndarray(data, { #data }, { 1 }, 0, "number")
	end

	return
end

--- Performs a SVD decomposition, returning U, Vt and the matrix's singular values.
---@within linalg
---@method svd
---@param matrix ndArray
---@return (ndArray,ndArray,ndArray)
module.svd = function(
	matrix: types.ndArray<number>
): (types.ndArray<number>, types.ndArray<number>, types.ndArray<number>)
	local matrix_t = matrix:transpose()

	local sym_l = module.matmul(matrix, matrix_t)
	local sym_r = module.matmul(matrix_t, matrix)

	local eigenvalues_l, U = module.eig(sym_l)
	local eigenvalues_r, V = module.eig(sym_r)

	local singular_values = eigenvalues_r:copy()

	for i, v in singular_values do
		singular_values[i] = sqrt(math.max(v, 0))
	end

	local indices_l = table.create(#eigenvalues_l)
	for i = 1, #eigenvalues_l do
		indices_l[i] = i
	end

	table.sort(indices_l, function(a, b)
		return eigenvalues_l[a] > eigenvalues_l[b]
	end)

	local U_sorted = U:copy()

	for i, index in ipairs(indices_l) do
		U_sorted[`:,{i}`] = U[`:,{index}`]
	end

	local indices_r = table.create(#eigenvalues_r)
	for i = 1, #eigenvalues_r do
		indices_r[i] = i
	end

	table.sort(indices_r, function(a, b)
		return eigenvalues_r[a] > eigenvalues_r[b]
	end)

	local V_sorted = V:copy()
	for i, index in ipairs(indices_r) do
		V_sorted[`:,{i}`] = V[`:,{index}`]
	end

	table.sort(singular_values.Buffer, function(a, b)
		return a > b
	end)

	return U_sorted, singular_values, V_sorted:transpose()
end

--- Preforms a least squares fit on x and y, producing the coefficents of degree `degree` in descending order
--- degree defaults to 0.
---@within linalg
---@method lstsq
---@param x ndArray
---@param y ndArray
---@param degree number
---@return ndArray
module.lstsq = function(x: types.ndArray<number>, y: types.ndArray<number>, degree: number): types.ndArray<number>
	local order = degree + 1

	local vandemonde = constructors.vander(x, order)

	local U, sigma, Vt = module.svd(vandemonde)

	local scaled_coef = ndarray(table.create(order, 0), { order }, { 1 }, 0, "number")
	local fuzzy = 1e-9

	local Ut_y = module.matmul(U:transpose(), y)

	for i = 1, order do
		local sig_value = sigma.Buffer[i]

		local inverse_sigma = if abs(sig_value) > fuzzy then 1 / sig_value else 0

		scaled_coef.Buffer[i] = inverse_sigma * Ut_y.Buffer[i]
	end

	return module.matmul(Vt:transpose(), scaled_coef)
end

return module :: interface
