local module = {}
local types = require("../types")
local ndArray_utils = require("../utility/ndarray")

local exceptions = require("../Exceptions")
local ndarray = require("../ndarray/ndarray")

local aggregations = require("./aggregations")

local constructors = require("../ndarray/constructors")

export type interface = {
    matmul : (A : types.ndArray<number>,B : types.ndArray<number>) -> types.ndArray<number>,
    dot : (A : types.ndArray<number>,B : types.ndArray<number>) -> types.ndArray<number>,
    det : (matrix : types.ndArray<number>) -> types.ndArray<number>,
    cross : (A : types.ndArray<number>,B : types.ndArray<number>) -> types.ndArray<number>,
    eigenval : (matrix : types.ndArray<number>) -> types.ndArray<number>,
    eig : (matrix : types.ndArray<number>) -> (types.ndArray<number>, types.ndArray<number>),
    qr : (matrix : types.ndArray<number>) -> types.ndArray<number>,
    lu : (matrix : types.ndArray<number>) -> (types.ndArray<number>,types.ndArray<number>,{number},number),
    solve : (A : types.ndArray<number>,B: types.ndArray<number>) -> types.ndArray<number>,
    svd : (A : types.ndArray<number>) -> (types.ndArray<number>,types.ndArray<number>,types.ndArray<number>),
    lstsq : (x : types.ndArray<number>,y : types.ndArray<number>,degree : number) -> types.ndArray<number>
}

module.matmul = function(A : types.ndArray<number>,B : types.ndArray<number>)
    if A.ndim == 2 and B.ndim == 1 then
        local A_row = A.Shape[1]
        local A_column = A.Shape[2]
 
        local B_len = B.Shape[1]

        if B_len ~= A_column then
            exceptions.FormatException("Value", "matrix vector multiplication requires vector length = matrix column length")
        end

        local Shape = {A_row}
        local Strides = ndArray_utils.ComputeStrides(Shape)
        
        local result = ndarray(table.create(A_row,0),Shape, Strides, 0, A.dtype)

        for i = 1, A_row do
            for j = 1, A_column do
                result[i] += A[i][j] * B[j]
            end
        end

        return result
    end


    if A.ndim ~= 2 or B.ndim ~= 2 then
        exceptions.FormatException("Value", "matrix multiplication needs A.ndim = B.ndim")
    end

    local A_row = A.Shape[1]
    local A_column = A.Shape[2]

    local B_row = B.Shape[1]
    local B_column = B.Shape[2]

    if A_column ~= B_row then
        exceptions.FormatException("Value", "matrix multiplication needs A's column length = B's row length")
    end

    local Shape = {A_row,B_column}
    local Strides = ndArray_utils.ComputeStrides(Shape)
    
    local result = ndarray(table.create(A_row * B_column,0),Shape, Strides, 0, A.dtype)

    for i = 1,A_row do
        for j = 1,B_column do
            local sum = 0
            for k = 1,B_row do
                sum += A[i][k] * B[k][j]
            end
            result[i][j] = sum
        end
    end

    return result
end

module.lu = function(matrix : types.ndArray<number>)
    local n = matrix.Shape[1]
    local U = matrix:copy()
    
    local L_data = ndArray_utils.IdentityBuffer(n)
    local L = ndarray(L_data, {n,n}, {n,1}, 0, matrix.dtype)

    local P = {}
    for i = 1,n do P[i] = i end

    local swaps = 0

    for k = 1,n do
        local pivot_row = k
        local max_value = math.abs(U[k][k])
        for i = k + 1, n do
            local value = math.abs(U[i][k])
            if value <= max_value then continue end
            max_value = value
            pivot_row = i
        end

        if max_value < 1e-9 then 
            return nil,nil,swaps 
        end
        
        if pivot_row ~= k then
            for j = 1, n do
                U[k][j], U[pivot_row][j] = U[pivot_row][j],U[k][j]
            end

            for j = 1, k - 1 do
                L[k][j], L[pivot_row][j] = L[pivot_row][j], L[k][j]
            end

            P[k],P[pivot_row] = P[pivot_row],P[k]

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

    return L,U,P,swaps
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

    local _,U,_,swaps = module.lu(matrix)

    if not U then return ndarray({0},{},{},0,matrix.dtype) end

    local result = swaps % 2 == 0 and 1 or -1

    for i = 1,n do
        result *= U[i][i]
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
    if #A ~= #B then return end 

    local product = A * B
    local result = aggregations.sum(product)

    return result
end

module.cross = function(A : types.ndArray<number>,B : types.ndArray<number>)
    if A.ndim > 1 or B.ndim > 1 then
        exceptions.FormatException("LinAlg","cross product not implemented for ndim > 1")
    elseif A.ndim == 0 or B.ndim == 0 then
        exceptions.FormatException("LinAlg","cross product undefined for 0d ndArrays")
    end

    if #A ~= #B then return end 
    if #A ~= 3 then
        exceptions.FormatException("LinAlg","cross product only available between 3d vectors")
    end

    return ndarray({
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

        local raw_v = {}
        local v_len = n - k + 1

        raw_v[1] = R[k][k] - alpha
        for i = 2, v_len do
            raw_v[i] = R[k + i - 1][k]
        end

        local v = ndarray(raw_v, {v_len}, {1}, 0, matrix.dtype)
        local v_norm = module.norm(v)

        if v_norm ~= 0 then
            v /= v_norm
        end

        for j = k,n do
            local dot = 0
            for i = k,n do
                dot += v.Buffer[i - k + 1] * R[i][j]
            end

            for i = k,n do
                R[i][j] -= 2 * v.Buffer[i - k + 1] * dot
            end
        end

        for i = 1,n do
            local dot = 0
            for j = k,n do
                dot += Q[i][j] * v.Buffer[j - k + 1]
            end

            for j = k,n do
                Q[i][j] -= 2 * dot * v.Buffer[j - k + 1]
            end
        end
    
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

        return ndarray({v1,v2}, {2}, {1}, 0, matrix.dtype)
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

    return ndarray(result, {n}, {1}, 0, matrix.dtype)
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

        local fuzzy_factor = 1e-12


        local ev1_x = if math.abs(matrix[1][2]) > fuzzy_factor then 1 elseif math.abs(matrix[2][1]) > fuzzy_factor then -(matrix[2][2] - v1) / matrix[2][1] else 1
        local ev1_y = if math.abs(matrix[1][2]) > fuzzy_factor then -(matrix[1][1] - v1) / matrix[1][2] elseif math.abs(matrix[2][1]) > fuzzy_factor then 1 else 0

        local ev2_x = if math.abs(matrix[1][2]) > fuzzy_factor then 1 elseif math.abs(matrix[2][1]) > fuzzy_factor then -(matrix[2][2] - v2) / matrix[2][1] else 1
        local ev2_y = if math.abs(matrix[1][2]) > fuzzy_factor then -(matrix[1][1] - v2) / matrix[1][2] elseif math.abs(matrix[2][1]) > fuzzy_factor then 1 else 0

        local ev1_length = math.sqrt(ev1_x ^ 2 + ev1_y ^ 2)
        local ev2_length = math.sqrt(ev2_x ^ 2 + ev2_y ^ 2)

        ev1_x /= ev1_length
        ev1_y /= ev1_length
        
        ev2_x /= ev2_length
        ev2_y /= ev2_length
        
        return ndarray({v1,v2}, {2}, {1}, 0, matrix.dtype), ndarray({ev1_x,ev2_x,ev1_y,ev2_y}, {2,2}, {2,1}, 0, matrix.dtype)
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
            eigen_vectors = module.matmul(eigen_vectors,Q)
        end

    end

    local result = {}
    for i = 1,n do
        table.insert(result,Ak[i][i])
    end

    return ndarray(result, {n}, {1}, 0, matrix.dtype),eigen_vectors
end

module.solve = function(A : types.ndArray<number>,B: types.ndArray<number>)
    if A.ndim ~= 2 then
        exceptions.FormatException("LinAlg", "coefficient matrix must be ndim = 2")
    end

    if B.ndim ~= 1 then
        exceptions.FormatException("LinAlg", "ordinate ndarray must be ndim = 1")
    end

    if A.Shape[1] ~= A.Shape[2] then
        exceptions.FormatException("LinAlg", "coefficient matrix must be a square matrix")
    end

    -- solving the equation Ax = B
    -- where A = LU
    local L,U,P = module.lu(A)
    local n = A.Shape[1]
    if not L then
        exceptions.FormatException("LinAlg", "A has no inverse")
    end

    local Y = table.create(n,0)
    local X_data = table.create(n,0)

    -- forwards sub to solve LY = B
    for i = 1,n do
        local permuted_row = P[i]
        local b_value = B[permuted_row]
        local sum = 0

        for j = 1,i - 1 do
            sum += L[i][j] * Y[j]
        end

        Y[i] = b_value - sum
    end

    -- backwards sub to solve UX = Y
    for i = n,1,-1 do
        local sum = 0
        for j = i + 1,n do
            sum += U[i][j] * X_data[j]
        end

        X_data[i] = (Y[i] - sum) / U[i][i]
    end


    return ndarray(X_data, {n}, {1}, 0, A.dtype)
end

module.norm = function(A : types.ndArray<number>,axis : number,order : number)
    order = order or 2
    axis = axis or 0

    if order == 1 then
        local target_axis = A.ndim - axis
        local axis_stride = A.Strides[target_axis]
        local axis_shape = A.Shape[target_axis]

        local data = {}

        ndArray_utils.ForEachSlice(A.Shape, A.Strides, axis, A.Offset, function(base: number)
            local sum_of_abs = 0

            for i = 0,axis_shape - 1 do
                local index = base + (i * axis_stride)
                sum_of_abs += math.abs(A.Buffer[index + 1])
            end

            if sum_of_abs == 0 then
                return
            end

            local length = math.sqrt(sum_of_abs)

            table.insert(data,length)
        end)  
        
        return ndarray(data, {#data}, {1}, 0, "number")
    end

    if order == 2 then
        local target_axis = A.ndim - axis
        local axis_stride = A.Strides[target_axis]
        local axis_shape = A.Shape[target_axis]

        local data = {}

        ndArray_utils.ForEachSlice(A.Shape, A.Strides, axis, A.Offset, function(base: number)
            local sum_of_squares = 0

            for i = 0,axis_shape - 1 do
                local index = base + (i * axis_stride)
                sum_of_squares += A.Buffer[index + 1] * A.Buffer[index + 1]
            end

            if sum_of_squares == 0 then
                return
            end

            local length = math.sqrt(sum_of_squares)

            table.insert(data,length)
        end)  
        
        return ndarray(data, {#data}, {1}, 0, "number")
    end
    
    return
end

module.svd = function(A : types.ndArray<number>) : (types.ndArray<number>,types.ndArray<number>,types.ndArray<number>)
    
    local sym_l = module.matmul(A, A:transpose())
    local sym_r = module.matmul(A:transpose(), A)

    local eigenvalues_l, U = module.eig(sym_l)
    local eigenvalues_r, V = module.eig(sym_r)

    local singular_values = eigenvalues_r:copy()

    for i,v in singular_values do
        singular_values[i] = math.sqrt(math.max(v,0))
    end

    local indices_l = table.create(#eigenvalues_l)
    for i = 1,#eigenvalues_l do
        indices_l[i] = i
    end

    table.sort(indices_l,function(a, b)
        return eigenvalues_l[a] > eigenvalues_l[b]
    end)

    local U_sorted = U:copy()

    for i,index in ipairs(indices_l) do
        U_sorted[`:,{i}`] = U[`:,{index}`]  
    end

    local indices_r = table.create(#eigenvalues_r)
    for i = 1,#eigenvalues_r do
        indices_r[i] = i
    end

    table.sort(indices_r,function(a, b)
        return eigenvalues_r[a] > eigenvalues_r[b]
    end)
    
    local V_sorted = V:copy()
    for i,index in ipairs(indices_r) do
        V_sorted[`:,{i}`] = V[`:,{index}`]  
    end

    table.sort(singular_values.Buffer,function(a, b)  
        return a > b
    end)

    return U_sorted,singular_values,V_sorted:transpose()
end

module.lstsq = function(x : types.ndArray<number>,y : types.ndArray<number>,degree : number) : types.ndArray<number>
    local order = degree + 1

    local vandemonde = constructors.vander(x,order)

    local U ,sigma ,Vt  = module.svd(vandemonde)

    local scaled_coef = ndarray(table.create(order,0), {order}, {1}, 0, "number")
    local fuzzy = 1e-9

    local Ut_y = module.matmul(U:transpose(),y)

    for i = 1,order do
        local sig_value = sigma.Buffer[i]

        local inverse_sigma = if math.abs(sig_value) > fuzzy then 1 / sig_value else 0

        scaled_coef.Buffer[i] = inverse_sigma * Ut_y.Buffer[i]
    end

    return module.matmul(Vt:transpose(),scaled_coef)
end

return module :: interface