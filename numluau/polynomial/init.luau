--!strict
local types = require("./types")
local polynomial = require("@self/polynomial")
local poly_utils = require("./utility/poly")
local module = {}

module.fit = function(x : types.ndArray<number>,y : types.ndArray<number>,degree : number)
    local coef = poly_utils.fit(x, y, degree)
    
    return polynomial.new(coef,{
            math.min(unpack(x:toflatlist())),
            math.max(unpack(x:toflatlist()))
        }
    )
end

module.fromroots = function(roots : {number})
    local coef = {1}

    for _,root in ipairs(roots) do
        local new_coef = table.create(#coef + 1,0)

        for i = 1,#coef do
            new_coef[i] -= coef[i] * root 
            new_coef[i + 1] += coef[i]
        end

        coef = new_coef
    end

    return polynomial.new(coef)
end

return setmetatable(module, {
    __call = function(_,coef : {number},domain : {number},window : {number},symbol : string) : types.Polynomial
        return polynomial.new(coef,domain,window) :: types.Polynomial
    end
}) :: setmetatable<{
    fit : (x : types.ndArray<number>,y : types.ndArray<number>,degree : number) -> types.Polynomial,
    fromroots : (roots : {number}) -> types.Polynomial,

},{
    __call : (nil,coef : {number},domain : {number},window : {number},symbol : string) -> types.Polynomial
}>
