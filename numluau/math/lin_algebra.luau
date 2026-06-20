local module = {}
local types = require("../types")
local ndArray = require("../ndarray/ndarray")

local ndArray_utils = require("../ndarray/ndarray_utils")

local exceptions = require("../Exceptions")
local ndarray = require("../ndarray/ndarray")

export type interface = {
    matmul : (A : types.ndArray<number>,B : types.ndArray<number>) -> types.ndArray<number>,
    dot : (A : types.ndArray<number>,B : types.ndArray<number>) -> types.ndArray<number>,
    det : (A : types.ndArray<number>) -> types.ndArray<number>,
    cross : (A : types.ndArray<number>,B : types.ndArray<number>) -> types.ndArray<number>,
}

module.matmul = function(A : types.ndArray<number>,B : types.ndArray<number>)
    if A.ndim ~= 2 or B.ndim ~= 2 then return end

    local width = A.Shape[1]
    local n = A.Shape[2]

    local height = B.Shape[1]
    local n2 = B.Shape[2]

    if n ~= n2 then return end

    local result = {}

    local Shape = {width,height}
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
        return
    end

    if matrix.Shape[1] ~= matrix.Shape[2] then
         exceptions.FormatException("LinAlg", "determinant only works for square matrices")
        return
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
        print("for 2d ndArrays, its better to use numluau.matmul instead of numluau.dot")
        return module.matmul(A, B)
    elseif A.ndim == 0 and B.ndim == 0 then
        print("for 0d ndArrays, its better to use the * operator instead of numluau.dot")
        return A * B
    end


    if A.ndim ~= 1 or B.ndim ~= 1 then return end
    if #A.Buffer ~= #B.Buffer then return end 

    local result = 0
    for i = 1,#A.Buffer do
        result += A.Buffer[i] * B.Buffer[i]
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

return module :: interface