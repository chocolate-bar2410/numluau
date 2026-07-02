local types = require("../types")
local ndArray = require("../ndarray/ndarray")

local poly_utils = require("../utility/polynomial")

local exceptions = require("../Exceptions")

local interface = {}
local schema = {}

local meta = {__index = schema}

interface.new = function(coef : {number},domain : {number},window : {number},symbol : string) : types.Polynomial
    local polynomial = {}

    polynomial.coef = ndArray(coef, {#coef}, {1}, 0, "number")
    polynomial.domain = domain or {-1,1}
    polynomial.window = window or {-1,1}
    polynomial.symbol = symbol or 'x'

    return setmetatable(polynomial, meta) :: types.Polynomial
end

meta.__call = function(self : types.Polynomial, value : types.ndArray<number> | number)
    
    if typeof(value) == "number" then
        local result = 0
        for i,v in self.coef do
            result += (value ^ (i - 1)) * v
        end

        return result
    end

    local data = {}

    for i,val in value do
        local result = self(val)

        data[i] = result
    end

    return ndArray(data, table.clone(value.Shape), table.clone(value.Strides), 0, "number")
end

meta.__tostring = function(self : types.Polynomial)
    return poly_utils.prettyprint(self)
end

schema.degree = function(self : types.Polynomial)
    return self.coef.Shape[1] - 1
end

schema.cutdeg = function(self : types.Polynomial,degree : number)
    if degree > self.coef.Shape[1] - 1 then
        exceptions.FormatException("Poly", ("cutting degree %s must be less than the current degree %s"):format(degree,self:degree()))
    end
    if degree < 0 then
        exceptions.FormatException("Poly", ("cutting degree %s must be greater than 0"):format(degree))
    end


    local new_data = {}
    table.move(self.coef.Buffer,1,degree + 1,1,new_data)

    return interface.new(
        new_data,
        table.clone(self.domain),
        table.clone(self.window),
        self.symbol
    )
end

schema.copy = function(self : types.Polynomial)
    return interface.new(
        table.clone(self.coef.Buffer),
        table.clone(self.domain),
        table.clone(self.window),
        self.symbol
    )
end


return interface
