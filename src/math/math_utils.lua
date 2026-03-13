local module = {}
local Package = script.Parent.Parent

local types = require(Package.types)

local Exclude = {"random","lerp","map",
"max","min","clamp",
"noise","randomseed","isinf",
"isnan","atan2","isfinite","ldexp","frexp","fmod","pow"
}
local Map = function(ndArray : types.ndArray,callback,...)
    local copy = ndArray:copy()

    for i = 1,#copy.Buffer do
        copy.Buffer[i] = callback(copy.Buffer[i],...)
    end

    return copy
end

for i,v in math do
    if typeof(v) ~= "function" then continue end
    if table.find(Exclude, i) then continue end
    module[i] = function(ndArray : types.ndArray)
        return Map(ndArray,v)
    end
end

function module.log2(ndArray : types.ndArray)
    return Map(ndArray,math.log,2)
end


return module :: {
    log : (types.ndArray) -> types.ndArray,
    deg : (types.ndArray) -> types.ndArray,
    cosh : (types.ndArray) -> types.ndArray,
    round : (types.ndArray) -> types.ndArray,
    tanh : (types.ndArray) -> types.ndArray,
    floor : (types.ndArray) -> types.ndArray,
    sqrt : (types.ndArray) -> types.ndArray,
    modf : (types.ndArray) -> types.ndArray,
    acos : (types.ndArray) -> types.ndArray,
    tan : (types.ndArray) -> types.ndArray,
    cos : (types.ndArray) -> types.ndArray,
    atan : (types.ndArray) -> types.ndArray,
    sign : (types.ndArray) -> types.ndArray,
    ceil : (types.ndArray) -> types.ndArray,
    abs : (types.ndArray) -> types.ndArray,
    exp : (types.ndArray) -> types.ndArray,
    sinh : (types.ndArray) -> types.ndArray,
    asin : (types.ndArray) -> types.ndArray,
    rad : (types.ndArray) -> types.ndArray,
    log10 : (types.ndArray) -> types.ndArray,
    sin : (types.ndArray) -> types.ndArray,

    log2 : (types.ndArray) -> types.ndArray,
}