local schema = {}
local meta = {}

meta.__index = function(ndarray,index)
    if typeof(index) == "number" then return ndarray.data[index] end

    return ndarray[index] or schema[index]
end


local function ProcessArray(array : {},prevndim : number?,prevshape : {}?)
    local ndim = prevndim or 0
    local isvalid = true
    local shape = prevshape or {#array}

    if typeof(array) ~= "table" then return true,0,{} end

    local SameSize = true
    local Size = nil 
    local Recursive = false

    for i, v in array do
        if not Size then 
            Size = #v 
            print(v,Size)
            continue 
        end

        Recursive = Recursive or typeof(v) == "table"

        SameSize = #v == Size
    end
 
    if not Recursive then return true,1,{#array} end

    if not SameSize then 
        error("Malformed array: Array elements must be the same size")
        return false 
    end

    local SameDimension = true
    local Dimension = nil

    for i, v in array do
        local Valid,Newndim = ProcessArray(v,ndim,shape)

        isvalid = isvalid and Valid

        if not Dimension then 
            Dimension = Newndim
            continue 
        end

        SameDimension = Newndim == Dimension
    end

    ndim = Dimension + 1
   
    shape[ndim] = Size

    if not SameDimension then 
        error("Malformed array: Array elements must have the same dimensionality")
        return false
    end

    return isvalid,ndim,shape
end


return function(array : {})
    local ndArray = {}
    ndArray.Data = array
    ndArray.Shape = {}

    local valid,ndim,shape = ProcessArray(array)
    print(valid,ndim,shape)
    if valid ~= true then return end

    local i,j = 1,#shape
    while i > j do
        shape[i], shape[j] = shape[j],shape[i]
        i += 1
        j -= 1
    end

    ndArray.ndim = ndim
    ndArray.Shape = shape

    return ndArray
end