local module = {}
local Package = script.Parent.Parent
local types = require(Package.types)
local Broadcast = require(Package.ndarray.Broadcast)
local ndArray_utils = require(Package.ndarray.ndarray_utils)
local ndArray = require(Package.ndarray)

function module.greater(x1 : types.ndArray<any>,x2 : types.ndArray<any>)
    local Result,OutShape = Broadcast.CreateBroadcastArray(x1,x2,function(a,b) return a > b end)
    Result = ndArray(Result,OutShape,ndArray_utils.ComputeStrides(OutShape),0,"boolean")

    return Result
end

function module.greater_equal(x1 : types.ndArray<any>,x2 : types.ndArray<any>)
    local Result,OutShape = Broadcast.CreateBroadcastArray(x1,x2,function(a,b) return a >= b end)
    Result = ndArray(Result,OutShape,ndArray_utils.ComputeStrides(OutShape),0,"boolean")
    
    return Result
end

function module.less(x1 : types.ndArray<any>,x2 : types.ndArray<any>)
    local Result,OutShape = Broadcast.CreateBroadcastArray(x1,x2,function(a,b) return a < b end)
    Result = ndArray(Result,OutShape,ndArray_utils.ComputeStrides(OutShape),0,"boolean")
    
    return Result
end

function module.less_equal(x1 : types.ndArray<any>,x2 : types.ndArray<any>)
    local Result,OutShape = Broadcast.CreateBroadcastArray(x1,x2,function(a,b) return a <= b end)
    Result = ndArray(Result,OutShape,ndArray_utils.ComputeStrides(OutShape),0,"boolean")
    
    return Result
end

function module.equal(x1 : types.ndArray<any>,x2 : types.ndArray<any>)
    local Result,OutShape = Broadcast.CreateBroadcastArray(x1,x2,function(a,b) return a == b end)
    Result = ndArray(Result,OutShape,ndArray_utils.ComputeStrides(OutShape),0,"boolean")
    
    return Result
end

function module.not_equal(x1 : types.ndArray<any>,x2 : types.ndArray<any>)
    local Result,OutShape = Broadcast.CreateBroadcastArray(x1,x2,function(a,b) return a ~= b end)
    Result = ndArray(Result,OutShape,ndArray_utils.ComputeStrides(OutShape),0,"boolean")
    
    return Result
end

return module :: {
    greater : (x1 : types.ndArray<any>,x2 : types.ndArray<any>) -> types.ndArray<boolean>,
    greater_equal : (x1 : types.ndArray<any>,x2 : types.ndArray<any>) -> types.ndArray<boolean>,
    less : (x1 : types.ndArray<any>,x2 : types.ndArray<any>) -> types.ndArray<boolean>,
    less_equal : (x1 : types.ndArray<any>,x2 : types.ndArray<any>) -> types.ndArray<boolean>,
    equal : (x1 : types.ndArray<any>,x2 : types.ndArray<any>) -> types.ndArray<boolean>,
    not_equal : (x1 : types.ndArray<any>,x2 : types.ndArray<any>) -> types.ndArray<boolean>,
}