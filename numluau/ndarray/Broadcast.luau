local module = {}

local utils = require("../utility/ndarray")
local types = require("../types")
local exceptions = require("../Exceptions")

module.BroadcastShape = function<T>(ShapeA : {number},ShapeB : {number})
    local result = {}
    local lenA = #ShapeA
    local lenB = #ShapeB

    local OutRank = math.max(lenA,lenB)
    for i = 0,OutRank - 1 do
        local dimA = ShapeA[lenA - i] or 1 
        local dimB = ShapeB[lenB - i] or 1

        if dimA ~= dimB and dimA ~= 1 and dimB ~= 1 then
            exceptions.FormatException("Broadcasting","Tried to broadcast incompatible arrays")
        end

        result[OutRank - i] = math.max(dimA,dimB)
    end

    return result
end

module.ComputeBroadcastStrides = function<T>(Shape : {number}, Strides : {number}, TargetShape : {number})
    local result = {}
    local OriginalRank = #Shape
    local TargetRank = #TargetShape
    local Offset = TargetRank - OriginalRank

    for Axis = 1, TargetRank do
        local Dim = Shape[Axis - Offset] or 1
        local Stride = Strides[Axis - Offset] or 0

        if Dim == 1 then
            result[Axis] = 0
        else
            result[Axis] = Stride
        end
    end

    return result
end

module.BroadcastTo = function<T>(ndArray : types.ndArray<T>,TargetShape : {number})
    local NewStrides = module.ComputeBroadcastStrides(ndArray.Shape,ndArray.Strides,TargetShape)
    local ArrayView = ndArray:view()
    ArrayView.Strides = NewStrides
    ArrayView.Shape = TargetShape

    return ArrayView
end

module.BroadcastScalar = function<T>(A : types.ndArray<T> | T,B : types.ndArray<T> | T,Callback : (A : T,B : T) -> T)
    local not_ndarray : T = type(A) ~= "table" and A or B
    local _ndarray : types.ndArray<T> = type(A) == "table" and A or B
    
    local result = {}

    for i = 1,#_ndarray.Buffer do
        if typeof(A) ~= "table" then
            result[#result + 1] = Callback(not_ndarray,_ndarray.Buffer[i])
        else
            result[#result + 1] = Callback(_ndarray.Buffer[i],not_ndarray)
        end            
    end

    return result,_ndarray.Shape
end

module.CreateBroadcastArray = function<T>(A : types.ndArray<T>,B : types.ndArray<T>,Callback : (A : T,B : T) -> T)
    if typeof(A) ~= "table" or typeof(B) ~= "table" then return module.BroadcastScalar(A, B, Callback) end

    local Result = {}

    local OutShape = module.BroadcastShape(A.Shape,B.Shape)

    local A_view = module.BroadcastTo(A,OutShape)
    local B_view = module.BroadcastTo(B,OutShape)

    local Size = 1
    for i = 1,#OutShape do Size *= OutShape[i] end
    for i = 1,Size do table.insert(Result,0) end

    for i = 1,Size do
        local indexA = utils.FlatIndex(A_view,i - 1)
        local indexB = utils.FlatIndex(B_view,i - 1)

        Result[i] = Callback(A_view.Buffer[indexA + 1],B_view.Buffer[indexB + 1])
    end

    return Result,OutShape
end

return module