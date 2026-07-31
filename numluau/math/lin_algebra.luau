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

--- Performs a QR decomposition on the matrix, returning a orthogonal matrix Q and a upper triangular matrix R.
---@within linalg
---@method qr
---@param matrix ndArray
---@return (ndArray,ndArray)
module.qr = function(matrix: types.ndArray<number>)
	local m: number = matrix.Shape[1]
	local n: number = matrix.Shape[2]
	local Q: types.ndArray<number> = matrix:eye()
	local R: types.ndArray<number> = matrix:copy()

	-- householder reflections
	-- HₙHₙ₋₁...H₁A = R
	-- Q = HₙHₙ₋₁...H₁ since H is orthogonal
	for k = 1, math.min(m - 1, n) do
		local alpha = module.norm(R[`{k}:,{k}`]):item()
		if R[k][k] == 0 then continue end

		if R[k][k] > 0 then alpha = -alpha end

		local raw_v = {}
		local v_len = m - k + 1

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
			for i = k, m do
				dot += raw_v[i - k + 1] * R[i][j]
			end

			for i = k, m do
				R[i][j] -= 2 * raw_v[i - k + 1] * dot
			end
		end

		for i = 1, m do
			local dot = 0
			local Q_row = Q[i]
			for j = k, n do
				dot += Q_row[j] * raw_v[j - k + 1]
			end

			for j = k, n do
				Q_row[j] -= 2 * dot * raw_v[j - k + 1]
			end
		end
	end

	-- to remove float point imprecissions in R
	for i = 2, m do
		local R_row = R[i]
		for k = 1, i - 1 do
			R_row[k] = 0
		end
	end

	-- sign flip corrections for Q and R
	for k = 1, math.min(m, n) do
		local R_row = R[k]
		if R_row[k] >= 0 then continue end

		R_row[`{k} : {n}`] = -R_row[`{k} : {n}`]

		for i = 1, n do
			Q[i][k] = -Q[i][k]
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

	local tolerance = 1e-16

	local max_iterations = 1000
	local iterations = 0

	local diff = 1
	local maximum = -math.huge

	repeat
		local identity = Ak:eye():reshape(n, n)
		local shift = identity * Ak[-1][-1]

		Q, R = module.qr(Ak - shift)
		Ak = module.matmul(R, Q) + shift

		iterations += 1

		local new_max = -math.huge
		for i = 1, n do
			new_max = math.max(Ak[i][i], new_max)
		end

		diff = abs(maximum - new_max)
		maximum = new_max

	until diff < tolerance or iterations >= max_iterations

	local result = {}
	for i = 1, n do
		table.insert(result, Ak[i][i])
	end

	return ndarray(result, { n }, { 1 }, 0, matrix.dtype)
end

local hessenberg = function(matrix: types.ndArray<number>): (types.ndArray<number>, types.ndArray<number>)
	local n = matrix.Shape[1]

	local H = matrix:copy()
	local Q = matrix:eye():reshape(n, n)

	for k = 1, n - 2 do
		local v_len = n - k
		local v_sum2 = 0
		local raw_v = {}

		for i = 1, v_len do
			local value = H[k + i][k]
			raw_v[i] = value
			v_sum2 += value ^ 2
		end

		local norm = sqrt(v_sum2)

		if norm < 1e-14 then continue end

		local a1 = H[k + 1][k]
		local alpha = (a1 <= 0) and -norm or norm

		raw_v = { a1 - alpha }

		v_sum2 = (a1 - alpha) ^ 2

		for i = 2, v_len do
			raw_v[i] = H[k + i][k]
			v_sum2 += raw_v[i] ^ 2
		end

		if v_sum2 == 0 then continue end

		for j = k, n do
			local dot = 0
			for i = 1, v_len do
				dot += raw_v[i] * H[k + i][j]
			end

			dot *= 2 / v_sum2
			for i = 1, v_len do
				H[k + i][j] -= dot * raw_v[i]
			end
		end

		for i = 1, n do
			local dot = 0
			for j = 1, v_len do
				dot += H[i][k + j] * raw_v[j]
			end

			dot *= 2 / v_sum2
			for j = 1, v_len do
				H[i][k + j] -= dot * raw_v[j]
			end
		end

		for i = 1, n do
			local dot = 0
			for j = 1, v_len do
				dot += Q[i][k + j] * raw_v[j]
			end

			dot *= 2 / v_sum2
			for j = 1, v_len do
				Q[i][k + j] -= dot * raw_v[j]
			end
		end
	end

	return H, Q
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
	local Ak: types.ndArray<number>, schur_vectors: types.ndArray<number> = hessenberg(matrix)

	local Q: types.ndArray<number>, R: types.ndArray<number> = module.qr(Ak)

	local tolerance = 1e-16

	local max_iterations = 200
	local iterations = 0

	repeat
		local identity = Ak:eye():reshape(n, n)
		local shift = identity * Ak[-1][-1]

		Q, R = module.qr(Ak - shift)
		Ak = module.matmul(R, Q) + shift

		schur_vectors = module.matmul(schur_vectors, Q)

		iterations += 1

		local sub_diagonal_sum = 0

		for i = 1, n - 1 do
			sub_diagonal_sum += abs(Ak[i + 1][i])
		end

	until sub_diagonal_sum < tolerance or iterations >= max_iterations

	local result = {}
	for i = 1, n do
		table.insert(result, Ak[i][i])
	end

	local eigen_vectors = constructors.zeros(n, n)

	for col = 1, n do
		local lambda = Ak[col][col]
		local y = table.create(n, 0)

		y[col] = 1

		-- backwards subsitution to solve for each eigen vector from schur vectors
		for k = col - 1, 1, -1 do
			local Ak_krow = Ak[k]
			local sum = 0
			for j = k + 1, col do
				sum += Ak_krow[j] * y[j]
			end

			local denom = Ak_krow[k] - lambda

			if abs(denom) > 1e-12 then
				y[k] = -sum / denom
			else
				y[k] = 0
			end
		end

		local norm = 0
		for i = 1, #y do
			norm += y[i] ^ 2
		end
		norm = sqrt(norm)

		if norm ~= 0 then
			for i = 1, #y do
				y[i] /= norm
			end
		end

		-- conversion to eigen vector
		for i = 1, n do
			local schur_row = schur_vectors[i]
			local eig_row = eigen_vectors[i]
			local sum = 0

			for j = 1, n do
				sum += schur_row[j] * y[j]
			end

			eig_row[col] = sum
		end
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

		if #data == 1 then return ndarray(data[1], {}, {}, 0, "number") end

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

		if #data == 1 then return ndarray(data[1], {}, {}, 0, "number") end

		return ndarray(data, { #data }, { 1 }, 0, "number")
	end

	return
end

local givens_rotation = function(a: number, b: number): (number, number)
	if abs(b) < 1e-15 then return 1, 0 end
	local hypot = sqrt(a * a + b * b)

	return a / hypot, b / hypot
end

--- Performs a SVD decomposition, returning U, Vt and the matrix's singular values.
---@within linalg
---@method svd
---@param matrix ndArray
---@return (ndArray,ndArray,ndArray)
module.svd = function(
	matrix: types.ndArray<number>
): (types.ndArray<number>, types.ndArray<number>, types.ndArray<number>)
	-- bidiagonalisation step
	-- using householder from top -> down and left -> right
	-- (HₙHₙ₋₁...H₁)A(Ĥ₁..Ĥₙ₋₁Ĥ)ₙ = B
	local m: number = matrix.Shape[1]
	local n: number = matrix.Shape[2]
	local bidiag: types.ndArray<number> = matrix:copy()

	local U: types.ndArray<number> = constructors.zeros(m, m)
	local V: types.ndArray<number> = constructors.zeros(n, n)

	for i = 1, m do
		U[i][i] = 1
	end

	for i = 1, n do
		V[i][i] = 1
	end

	for k = 1, math.min(m, n) do
		-- left -> right reflection

		local v_len = m - k + 1
		local x = {}
		local sigma = 0
		for i = 1, v_len do
			x[i] = bidiag[k + i - 1][k]
			sigma += x[i] ^ 2
		end
		sigma = sqrt(sigma)

		if sigma ~= 0 then
			x[1] = if x[1] >= 0 then x[1] + sigma else x[1] - sigma

			local v_norm = 0
			for i = 1, v_len do
				v_norm += x[i] ^ 2
			end
			v_norm = sqrt(v_norm)

			for i = 1, v_len do
				x[i] /= v_norm
			end

			for j = k, n do
				local dot = 0
				for i = 1, v_len do
					dot += x[i] * bidiag[k + i - 1][j]
				end

				for i = 1, v_len do
					bidiag[k + i - 1][j] = bidiag[k + i - 1][j] - 2 * x[i] * dot
				end
			end

			for j = 1, m do
				local dot = 0
				for i = 1, v_len do
					dot += U[k + i - 1][j] * x[i]
				end

				for i = 1, v_len do
					U[k + i - 1][j] = U[k + i - 1][j] - 2 * dot * x[i]
				end
			end
		end

		if k >= n then continue end
		-- up -> down reflection

		v_len = n - k
		x = {}
		sigma = 0
		for i = 1, v_len do
			x[i] = bidiag[k][k + i]
			sigma += x[i] ^ 2
		end
		sigma = sqrt(sigma)

		if sigma == 0 then continue end

		x[1] = if x[1] >= 0 then x[1] + sigma else x[1] - sigma

		local v_norm = 0
		for i = 1, v_len do
			v_norm += x[i] ^ 2
		end
		v_norm = sqrt(v_norm)

		for i = 1, v_len do
			x[i] /= v_norm
		end

		for i = 1, m do
			local dot = 0
			local bidiag_row = bidiag[i]
			for j = 1, v_len do
				dot += x[j] * bidiag_row[j + k]
			end

			for j = 1, v_len do
				bidiag_row[j + k] = bidiag_row[j + k] - 2 * x[j] * dot
			end
		end

		for i = 1, n do
			local dot = 0
			local V_row = V[i]
			for j = 1, v_len do
				dot += V_row[j + k] * x[j]
			end

			for j = 1, v_len do
				V_row[j + k] = V_row[j + k] - 2 * dot * x[j]
			end
		end
	end

	-- diagonalisation step
	-- givens rotations are done to eliminate non diagonal zero values from bidiagonalisation
	-- this is called bulge chasing
	-- wtf is this name bro :sob:

	local iterations = 0
	local max_iterations = 1000

	local tolerance = 1e-16

	repeat
		-- wilkinson shift calculations
		local d_n1: number = bidiag[n - 1][n - 1]
		local e_n1: number = bidiag[n - 1][n]

		local d_n: number = bidiag[n][n]

		local a: number = d_n1 * d_n1 + e_n1 * e_n1
		local b: number = d_n1 * e_n1
		local c: number = d_n * d_n

		local delta: number = (a - c) / 2
		local _sign: number = delta >= 0 and 1 or -1

		local mu: number = c - b * b / (delta + _sign * sqrt(delta * delta + b * b))
		local _cos: number, _sin: number = givens_rotation(bidiag[1][1] ^ 2 - mu, bidiag[1][1] * bidiag[1][2])

		-- bulge chasing
		for k = 1, n - 1 do
			-- right rotation
			for row = 1, m do
				local bidiag_row = bidiag[row]
				local bidiag_x = bidiag_row[k]
				local bidiag_y = bidiag_row[k + 1]

				bidiag_row[k] = _cos * bidiag_x - _sin * bidiag_y
				bidiag_row[k + 1] = _sin * bidiag_x + _cos * bidiag_y
			end

			for row = 1, n do
				local V_row = V[row]
				local V_x = V_row[k]
				local V_y = V_row[k + 1]

				V_row[k] = _cos * V_x - _sin * V_y
				V_row[k + 1] = _sin * V_x + _cos * V_y
			end

			-- left rotation
			_cos, _sin = givens_rotation(bidiag[k][k], bidiag[k + 1][k])

			local bi_diag_k = bidiag[k]
			local bi_diag_k1 = bidiag[k + 1]

			local U_k = U[k]
			local U_k1 = U[k + 1]
			for col = 1, n do
				local bidiag_x = bi_diag_k[col]
				local bidiag_y = bi_diag_k1[col]

				bi_diag_k[col] = _cos * bidiag_x - _sin * bidiag_y
				bi_diag_k1[col] = _sin * bidiag_x + _cos * bidiag_y
			end

			for col = 1, m do
				local U_x = U_k[col]
				local U_y = U_k1[col]

				U_k[col] = _cos * U_x - _sin * U_y
				U_k1[col] = _sin * U_x + _cos * U_y
			end

			if k == n - 1 then continue end

			_cos, _sin = givens_rotation(bidiag[k][k + 1], bidiag[k][k + 2])
		end

		local super_diagonal_sum = 0

		for i = 1, n - 1 do
			super_diagonal_sum += abs(bidiag[i][i + 1])
		end

		iterations += 1
	until iterations >= max_iterations or abs(super_diagonal_sum) < tolerance

	local singular_values: types.ndArray<number> = ndarray(table.create(n, 0), { n }, { 1 }, 0, bidiag.dtype)

	for i = 1, n do
		singular_values[i] = abs(bidiag[i][i])
	end

	for i = 1, n do
		for j = i + 1, n do
			if singular_values[i] >= singular_values[j] then continue end

			singular_values:swap(i, j)
			U:swap(i, j, 1)
			V:swap(i, j, 0)
		end
	end

	return U:transpose(), singular_values, V
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
