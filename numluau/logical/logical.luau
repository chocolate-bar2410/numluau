local module = {}
local types = require("../types")
local Broadcast = require("../ndarray/Broadcast")
local ndArray_utils = require("../ndarray/ndarray_utils")
local ndArray = require("../ndarray/ndarray")

function module.logical_and(x1 : types.ndArray<any>,x2 : types.ndArray<any>)
    local Result,OutShape = Broadcast.CreateBroadcastArray(x1,x2,function(a,b) 
        a = a ~= 0 and a ~= false
        b = b ~= 0 and b ~= false
        return a and b 
    end)
    Result = ndArray(Result,OutShape,ndArray_utils.ComputeStrides(OutShape),0,"boolean")
    
    return Result
end

function module.logical_or(x1 : types.ndArray<any>,x2 : types.ndArray<any>)
    local Result,OutShape = Broadcast.CreateBroadcastArray(x1,x2,function(a,b) 
        a = a ~= 0 and a ~= false
        b = b ~= 0 and b ~= false
        return a or b 
    end)
    Result = ndArray(Result,OutShape,ndArray_utils.ComputeStrides(OutShape),0,"boolean")
    
    return Result
end

function module.logical_xor(x1 : types.ndArray<any>,x2 : types.ndArray<any>)
    local Result,OutShape = Broadcast.CreateBroadcastArray(x1,x2,function(a,b) 
        a = a ~= 0 and a ~= false
        b = b ~= 0 and b ~= false
        return a ~= b 
    end)
    Result = ndArray(Result,OutShape,ndArray_utils.ComputeStrides(OutShape),0,"boolean")
    
    return Result
end

function module.logical_not(x1 : types.ndArray<boolean>)
    local Result = x1:copy()

    for i = 1,#Result.Buffer do
        Result[#Result + 1] = Result.Buffer[i] == 0 or Result.Buffer[i] == false
    end

    return Result
end


return module :: {
    logical_and : (x1 : types.ndArray<any>,x2 : types.ndArray<any>) -> types.ndArray<boolean>,
    logical_or : (x1 : types.ndArray<any>,x2 : types.ndArray<any>) -> types.ndArray<boolean>,
    logical_xor : (x1 : types.ndArray<any>,x2 : types.ndArray<any>) -> types.ndArray<boolean>,
    logical_not : (x1 : types.ndArray<any>,x2 : types.ndArray<any>) -> types.ndArray<boolean>,
}