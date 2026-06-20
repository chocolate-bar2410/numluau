local module = {}
local types = require("../types")
local ndArray = require("../ndarray/ndarray")

local ndArray_utils = require("../ndarray/ndarray_utils")

local exceptions = require("../Exceptions")

export type interface = {
    matmul : (A : types.ndArray<number>,B : types.ndArray<number>) -> types.ndArray<number>,
    dot : (A : types.ndArray<number>,B : types.ndArray<number>) -> types.ndArray<number>,
    det : (A : types.ndArray<number>) -> number
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
        return matrix[1][1] * matrix[2][2] - matrix[1][2] * matrix[2][1]
    end

    if matrix.Shape[1] == 3 then
        -- optimisation using sarrus's rule
        local aei = matrix[1][1] * matrix[2][2] * matrix[3][3]
        local bfg = matrix[2][1] * matrix[3][2] * matrix[1][3]
        local cdh = matrix[3][1] * matrix[1][2] * matrix[2][3]

        local gec = matrix[1][3] * matrix[2][2] * matrix[3][1]
        local hfa = matrix[2][3] * matrix[3][2] * matrix[1][1]
        local idb = matrix[3][3] * matrix[1][2] * matrix[2][1]

        return (aei + bfg + cdh) - (gec + hfa + idb)
    end

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

return module :: interface