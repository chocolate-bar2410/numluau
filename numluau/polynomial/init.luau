local types = require("./types")
local polynomial = require("@self/polynomial")
local module = {}

return setmetatable(module, {
    __call = function(_,coef : {number},domain : {number},window : {number},symbol : string) : types.Polynomial
        return polynomial.new(coef,domain,window) :: types.Polynomial
    end
})
