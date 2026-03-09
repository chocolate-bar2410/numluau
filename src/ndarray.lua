local schema = {}
local meta = {}

--[[
to do:
    - negative index column slicing
    - multidimensional slicing

reference:
    - https://www.youtube.com/watch?v=VXU4LSAQDSc
]]

local ReverseTable = function(tab)
    local i,j = 1,#tab
    while i > j do
        tab[i], tab[j] = tab[j],tab[i]
        i += 1
        j -= 1
    end

    return tab
end

local function Slice(tab,min,max,step)
    local Result = {}

    if step and step < 0 then
        for i = max,min,step do
            table.insert(Result,tab[i])
        end
        
        return Result
    end

    for i = min,max,step do
        table.insert(Result,tab[i])
    end
    
    return Result
end

local function ColSlice(tab,min,max,step)
    local Result = {}
    max = max or step and #tab or 1
    step = step or 1

    if step < 0 then
        for k = max,min,step do
            local SubResult = {}
            for i = 1,#tab do
                table.insert(SubResult,tab[i][k])
            end
            table.insert(Result,SubResult)
        end

        if #Result == 1 then return Result[1] end

        return Result
    end

    for k = min,max,step do
        local SubResult = {}
        for i = 1,#tab do
            table.insert(SubResult,tab[i][k])
        end
        table.insert(Result,SubResult)
    end

    if #Result == 1 then return Result[1] end

    return Result
    
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
        Recursive = Recursive or typeof(v) == "table"

        if not Size then 
            Size = Recursive and #v or 0
            continue 
        end

        if not Recursive then continue end

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

local New_ndarray = function(data : {})
    local ndArray = {}
    ndArray.Data = data
    ndArray.Shape = {}

    local valid,ndim,shape = ProcessArray(data)

    if valid ~= true then return end
    ReverseTable(shape)
    

    ndArray.ndim = ndim
    ndArray.Shape = shape

    return setmetatable(ndArray, meta)
end

meta.__index = function(ndarray,index)
    if typeof(index) == "number" then return ndarray.Data[index] end

    if typeof(index) == "table" then
        
        if typeof(index[1]) == "string" and index[1] == "slice" then
            return New_ndarray(Slice(ndarray.Data,index[2],index[3],index[4]))
        end

        if typeof(index[1]) == "string" and index[1] == "colslice" then
            return New_ndarray(ColSlice(ndarray.Data,index[2],index[3],index[4]))
        end
        local result = ndarray.Data

        for i = 1,#index do
            result = result[index[i]]
        end

        return result
    end

    return rawget(ndarray,index) or schema[index]
end





return New_ndarray