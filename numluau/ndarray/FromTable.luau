local utils = require("./ndarray_utils")
local types = require("../types")

local ndArray = require("./ndarray")
local Exceptions = require("../Exceptions")

local function ProcessArray(array : {},prevndim : number?,prevshape : {}?)
    local ndim = prevndim or 0
    local isvalid = true

    if typeof(array) ~= "table" then return true,0,{},typeof(array) end

    local shape = prevshape or {#array}

    local SameSize = true
    local Size = nil 
    local dtype = nil

    for i, v in array do
        dtype = typeof(v)

        if not Size then 
            Size = dtype == "table" and #v or 0
            continue 
        end

        if dtype ~= "table" then continue end

        SameSize = #v == Size
    end
 
    if dtype ~= "table" then return true,1,{#array},dtype end

    if not SameSize then 
        return false, "Array elements must be the same size"
    end

    local SameDimension = true
    local Dimension = nil

    for i, v in array do
        local Valid,Newndim,_,innerdtype = ProcessArray(v,ndim,shape)

        isvalid = isvalid and Valid

        if not Dimension then 
            Dimension = Newndim
            continue 
        end

        dtype = innerdtype

        SameDimension = Newndim == Dimension
    end

    ndim = Dimension + 1
   
    shape[ndim] = Size

    if not SameDimension then 
        return false,"Array elements must have the same dimensionality"
    end

    return isvalid,ndim,shape,dtype
end

return function(data : {}) : types.ndArray<any>
    local valid,Message,shape,dtype = ProcessArray(data)

    if valid ~= true then 
        Exceptions.FormatException("Malformed", Message)
        return 
    end
    local Buffer = {}
    
    if typeof(data) == "table" then
        utils.Flatten(data, Buffer)
    else
        table.insert(Buffer,data)
    end

    return ndArray(Buffer,shape,utils.ComputeStrides(shape),0,dtype) 
end