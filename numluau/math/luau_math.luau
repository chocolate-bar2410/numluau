local module = {}

local types = require("../types")

local Exclude = {"random","lerp","map",
"max","min","clamp",
"noise","randomseed","isinf",
"isnan","atan2","isfinite","ldexp","frexp","fmod","pow"
}
local Map = function(ndArray : types.ndArray<number>,callback,...)
    local copy = ndArray:copy()

    for i,v in copy do
        copy.Buffer[i] = callback(copy.Buffer[i],...)
    end

    return copy
end

for i,v in math do
    if typeof(v) ~= "function" then continue end
    if table.find(Exclude, i) then continue end
    module[i] = function(ndArray : types.ndArray<number>)
        return Map(ndArray,v)
    end
end

function module.log2(ndArray : types.ndArray<number>)
    return Map(ndArray,math.log,2)
end


return module :: {
    log : (types.ndArray<number>) -> types.ndArray<number>,
    deg : (types.ndArray<number>) -> types.ndArray<number>,
    cosh : (types.ndArray<number>) -> types.ndArray<number>,
    round : (types.ndArray<number>) -> types.ndArray<number>,
    tanh : (types.ndArray<number>) -> types.ndArray<number>,
    floor : (types.ndArray<number>) -> types.ndArray<number>,
    sqrt : (types.ndArray<number>) -> types.ndArray<number>,
    modf : (types.ndArray<number>) -> types.ndArray<number>,
    acos : (types.ndArray<number>) -> types.ndArray<number>,
    tan : (types.ndArray<number>) -> types.ndArray<number>,
    cos : (types.ndArray<number>) -> types.ndArray<number>,
    atan : (types.ndArray<number>) -> types.ndArray<number>,
    sign : (types.ndArray<number>) -> types.ndArray<number>,
    ceil : (types.ndArray<number>) -> types.ndArray<number>,
    abs : (types.ndArray<number>) -> types.ndArray<number>,
    exp : (types.ndArray<number>) -> types.ndArray<number>,
    sinh : (types.ndArray<number>) -> types.ndArray<number>,
    asin : (types.ndArray<number>) -> types.ndArray<number>,
    rad : (types.ndArray<number>) -> types.ndArray<number>,
    log10 : (types.ndArray<number>) -> types.ndArray<number>,
    sin : (types.ndArray<number>) -> types.ndArray<number>,

    log2 : (types.ndArray<number>) -> types.ndArray<number>,
}