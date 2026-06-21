local module = {}
local types = require("../types")
local ndArray = require("../ndarray/ndarray")

local ndArray_utils = require("../ndarray/ndarray_utils")

local exceptions = require("../Exceptions")
local ndarray = require("../ndarray/ndarray")

export type interface = {
    matmul : (A : types.ndArray<number>,B : types.ndArray<number>) -> types.ndArray<number>,
    dot : (A : types.ndArray<number>,B : types.ndArray<number>) -> types.ndArray<number>,
    det : (matrix : types.ndArray<number>) -> types.ndArray<number>,
    cross : (A : types.ndArray<number>,B : types.ndArray<number>) -> types.ndArray<number>,
    eigenval : (matrix : types.ndArray<number>) -> types.ndArray<number>,
    eig : (matrix : types.ndArray<number>) -> (types.ndArray<number>, types.ndArray<number>),
    qr : (matrix : types.ndArray<number>) -> types.ndArray<number>,
}

module.matmul = function(A : types.ndArray<number>,B : types.ndArray<number>)
    if A.ndim ~= 2 or B.ndim ~= 2 then return end

    local width = A.Shape[1]
    local n = A.Shape[2]

    local height = B.Shape[1]
    local n2 = B.Shape[2]

    if n ~= height then return end

    local result = {}

    local Shape = {width,n2}
    local Strides = ndArray_utils.ComputeStrides(Shape)

    for i = 1, height do
        for j = 1, width do
            local sum = 0
            for k = 1, n do
                local a = ndArray_utils.GetElement(A, {i,k})
                local b = ndArray_utils.GetElement(B, {k,j})
                sum = sum + a * b
            end

            local offset = (i - 1) * Strides[1] + (j - 1) * Strides[2]
            result[offset + 1] = sum
        end
    end

    return ndArray(result, Shape, Strides, 0, A.dtype)
end

module.det = function(matrix : types.ndArray<number>)
    if matrix.ndim ~= 2 then
        exceptions.FormatException("LinAlg", "determinant is only support for ndim = 2")
    end

    if matrix.Shape[1] ~= matrix.Shape[2] then
         exceptions.FormatException("LinAlg", "determinant only works for square matrices")
    end

    if matrix.Shape[1] == 2 then
        return ndarray({matrix[1][1] * matrix[2][2] - matrix[1][2] * matrix[2][1]},{},{},0,matrix.dtype)
    end

    if matrix.Shape[1] == 3 then
        -- optimisation using sarrus's rule
        local aei = matrix[1][1] * matrix[2][2] * matrix[3][3]
        local bfg = matrix[2][1] * matrix[3][2] * matrix[1][3]
        local cdh = matrix[3][1] * matrix[1][2] * matrix[2][3]

        local gec = matrix[1][3] * matrix[2][2] * matrix[3][1]
        local hfa = matrix[2][3] * matrix[3][2] * matrix[1][1]
        local idb = matrix[3][3] * matrix[1][2] * matrix[2][1]

        return ndarray({(aei + bfg + cdh) - (gec + hfa + idb)},{},{},0,matrix.dtype)
    end

    -- LU decomposition
    local n = matrix.Shape[1]
    local result_mat = matrix:copy()
    local swaps = 0

    for k = 1,n do
        local pivot_row = k
        local max_value = math.abs(result_mat[k][k])
        for i = k + 1, n do
            local value = math.abs(result_mat[i][k])
            if value <= max_value then continue end
            max_value = value
            pivot_row = i
        end

        if max_value == 0 then return ndarray({0},{},{},0,matrix.dtype) end
        
        if pivot_row ~= k then
            for j = 1, n do
                result_mat[k][j], result_mat[pivot_row][j] = result_mat[pivot_row][j],result_mat[k][j]
            end

            swaps += 1
        end

        local pivot = result_mat[k][k]
        for i = k + 1, n do
            local factor = result_mat[i][k] / pivot
            result_mat[i][k] = factor

            for j = k + 1, n do
                result_mat[i][j] = result_mat[i][j] - factor * result_mat[k][j]
            end
        end
    end

    local result = swaps % 2 == 0 and 1 or -1
    for i = 1,n do
        result *= result_mat[i][i]
    end

    return ndarray({result},{},{},0,matrix.dtype)
end

module.dot = function(A : types.ndArray<number>,B : types.ndArray<number>)
    if A.ndim == 2 and B.ndim == 2 then
        print("for 2d ndArrays, its better to use numluau.linalg.matmul instead of numluau.linalg.dot")
        return module.matmul(A, B)
    elseif A.ndim == 0 and B.ndim == 0 then
        print("for 0d ndArrays, its better to use the * operator instead of numluau.linalg.dot")
        return A * B
    end


    if A.ndim ~= 1 or B.ndim ~= 1 then return end
    if #A.Buffer ~= #B.Buffer then return end 

    local result = 0
    for i = 1,A.Shape[1] do
        result += A[i] * B[i]
    end

    return ndArray(result, {}, {}, 0, A.dtype)
end

module.cross = function(A : types.ndArray<number>,B : types.ndArray<number>)
    if A.ndim > 1 or B.ndim > 1 then
        exceptions.FormatException("LinAlg","cross product not implemented for ndim > 1")
    elseif A.ndim == 0 or B.ndim == 0 then
        exceptions.FormatException("LinAlg","cross product undefined for 0d ndArrays")
    end

    if #A.Buffer ~= #B.Buffer then return end 
    if #A.Buffer ~= 3 then
        exceptions.FormatException("LinAlg","cross product only available between 3d vectors")
    end

    return ndArray({
        A[2]*B[3] - A[3]*B[2],
        A[3]*B[1] - A[1]*B[3],
        A[1]*B[2] - A[2]*B[1]
    }, {3}, {1}, 0, A.dtype)
end

local function safe_col_dot(matrix, col_idx, start_row)
    local sum = 0
    local n = matrix.Shape[1]

    for i = start_row, n do
        local val = matrix[i][col_idx] 
        sum += val * val
    end
    
    return sum
end

module.qr = function(matrix : types.ndArray<number>)
    local n : number = matrix.Shape[1]
    local Q : types.ndArray<number> = matrix:eye()
    local R : types.ndArray<number> = matrix:copy()

    for k = 1,n - 1 do
        local dot_xx = safe_col_dot(R,k,k)
        local alpha = math.sqrt(dot_xx)

        if R[k][k] < 0 then alpha *= -1 end

        local v = {}
        local v_len = n - k + 1

        v[1] = R[k][k] - alpha
        for i = 2, v_len do
            v[i] = R[k + i - 1][k]
        end

        local dot_vv = 0
        for i = 1, v_len do
            dot_vv += v[i] * v[i]
        end
        local v_norm = math.sqrt(dot_vv)

        if v_norm ~= 0 then
            for i = 1, v_len do
                v[i] /= v_norm
            end
        end

        local H = matrix:eye()
        for i = k, n do
            for j = k, n do
                local vi = v[i - k + 1]
                local vj = v[j - k + 1]
                local init_val = (i == j) and 1 or 0
                H[i][j] = init_val - 2 * vi * vj
            end
        end

        R = module.matmul(H, R)
        Q = module.matmul(Q, H)
    
    end

    return Q,R
end
module.eigenval = function(matrix : types.ndArray<number>)
    if matrix.ndim ~= 2 then
        exceptions.FormatException("LinAlg", "eigenval is only support for ndim = 2")
    end

    if matrix.Shape[1] ~= matrix.Shape[2] then
        exceptions.FormatException("LinAlg", "non square matrices dont have eigenvalues")
    end

    if matrix.Shape[1] == 2 then
        local mean = (matrix[1][1] + matrix[2][2]) / 2
        local determinant = matrix[1][1] * matrix[2][2] - matrix[1][2] * matrix[2][1]

        local v1 = mean + math.sqrt(mean * mean - determinant)
        local v2 = mean - math.sqrt(mean * mean - determinant)

        return ndArray({v1,v2}, {2}, {1}, 0, matrix.dtype)
    end

    -- QR decomposition
    local n : number = matrix.Shape[1]
    local Ak = matrix:copy()
    local Q : types.ndArray<number>
    local R : types.ndArray<number>

    local iterations = 50

    for i = 1,iterations do
        Q,R = module.qr(Ak)
        Ak = module.matmul(R, Q)
    end

    local result = {}
    for i = 1,n do
        table.insert(result,Ak[i][i])
    end

    return ndArray(result, {n}, {1}, 0, matrix.dtype)
end

module.eig = function(matrix : types.ndArray<number>)
    if matrix.ndim ~= 2 then
        exceptions.FormatException("LinAlg", "eigenval is only support for ndim = 2")
    end

    if matrix.Shape[1] ~= matrix.Shape[2] then
        exceptions.FormatException("LinAlg", "non square matrices dont have eigenvalues")
    end

    if matrix.Shape[1] == 2 then
        local mean = (matrix[1][1] + matrix[2][2]) / 2
        local determinant = matrix[1][1] * matrix[2][2] - matrix[1][2] * matrix[2][1]

        local v1 = mean + math.sqrt(mean * mean - determinant)
        local v2 = mean - math.sqrt(mean * mean - determinant)

        local ev1_x
        local ev1_y
        local ev2_x
        local ev2_y

        local fuzzy_factor = 1e-9 -- to account for floating point percission

        if math.abs(v1 - v2) < fuzzy_factor then

            if math.abs(matrix[1][2]) < fuzzy_factor and math.abs(matrix[2][1]) < fuzzy_factor then
                ev1_x,ev1_y = 1,0
                ev2_x,ev2_y = 0,1
            else
                if math.abs(matrix[2][1]) > fuzzy_factor then
                    ev1_y = 1
                    ev1_x = -(matrix[2][2] - v1) / matrix[2][1]
                else
                    ev1_x = 1
                    ev1_y = -(matrix[1][1] - v1) / matrix[1][2]
                end

                local norm = math.sqrt(ev1_x*ev1_x + ev1_y*ev1_y)
                ev1_x, ev1_y = ev1_x / norm, ev1_y / norm

                ev2_x, ev2_y = ev1_x, ev1_y
            end

            
        else
            ev1_x = math.sqrt(math.abs((v1 - matrix[2][2])/(v1 - v2)))
            ev1_y = math.sqrt(math.abs((v1 - matrix[1][1])/(v1 - v2)))

            ev2_x = math.sqrt(math.abs((v2 - matrix[2][2])/(v2 - v1)))
            ev2_y = math.sqrt(math.abs((v2 - matrix[1][1])/(v2 - v1)))

            if matrix[1][2] < fuzzy_factor then
                ev1_y = -ev1_y
                ev2_y = -ev2_y
            end
        end
        
        return ndArray({v1,v2}, {2}, {1}, 0, matrix.dtype), ndarray({ev1_x,ev2_x,ev1_y,ev2_y}, {2,2}, {2,1}, 0, matrix.dtype)
    end

    -- QR decomposition
    local n : number = matrix.Shape[1]
    local Ak = matrix:copy()
    local Q : types.ndArray<number>
    local R : types.ndArray<number>

    local eigen_vectors
    local iterations = 50

    for i = 1,iterations do
        Q,R = module.qr(Ak)
        Ak = module.matmul(R, Q)

        if i == 1 then
            eigen_vectors = Q
        else
            eigen_vectors = module.matmul(Q, eigen_vectors)
        end

    end

    local result = {}
    for i = 1,n do
        table.insert(result,Ak[i][i])
    end

    return ndArray(result, {n}, {1}, 0, matrix.dtype),eigen_vectors
end

return module :: interface