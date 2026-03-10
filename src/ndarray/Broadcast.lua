local module = {}

local Package = script.Parent.Parent
local utils = require(script.Parent.ndarray_utils)
local types = require(Package.types)

module.BroadcastShape = function(ShapeA : {number},ShapeB : {number})
    local result = {}
    local lenA = #ShapeA
    local lenB = #ShapeB

    local OutRank = math.max(lenA,lenB)
    for i = 0,OutRank - 1 do
        local dimA = ShapeA[lenA - i] or 1 
        local dimB = ShapeB[lenB - i] or 1

        if dimA ~= dimB and dimA ~= 1 and dimB ~= 1 then
            error("Tried to broadcast incompatible arrays")
        end

        result[OutRank - i] = math.max(dimA,dimB)
    end

    return result
end

module.ComputeBroadcastStrides = function(Shape, Strides, TargetShape)
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

module.BroadcastTo = function(ndArray : types.ndArray,TargetShape)
    local NewStrides = module.ComputeBroadcastStrides(ndArray.Shape,ndArray.Strides,TargetShape)
    local ArrayView = ndArray:view()
    ArrayView.Strides = NewStrides
    ArrayView.Shape = TargetShape

    return ArrayView
end

module.CreateBroadcastArray = function<T>(A : types.ndArray,B : types.ndArray,Callback : (A : T,B : T) -> T)
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