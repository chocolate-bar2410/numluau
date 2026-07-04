local types = require("./types")
local polynomial = require("@self/polynomial")
local poly_utils = require("./utility/poly")
local module = {}

module.fit = function(x : types.ndArray<number>,y : types.ndArray<number>,degree : number)
    local coef = poly_utils.fit(x, y, degree)
    
    return polynomial.new(coef)
end


return setmetatable(module, {
    __call = function(_,coef : {number},domain : {number},window : {number},symbol : string) : types.Polynomial
        return polynomial.new(coef,domain,window) :: types.Polynomial
    end
})
