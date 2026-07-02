local types = require("../types")
local ndArray = require("../ndarray/ndarray")

local poly_utils = require("../utility/polynomial")
local linear_algebra = require("../math/lin_algebra")

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
            result += (i > 0 and (value ^ (i - 1)) or 1) * v
        end

        return result
    end

    local data = {}

    for i,val in value do
        local result = 0
        for i,v in self.coef do
            result += (i > 0 and (val ^ (i - 1)) or 1) * v
        end

        data[i] = result
    end

    return ndArray(data, table.clone(value.Shape), table.clone(value.Strides), 0, "number")
end

meta.__tostring = function(self : types.Polynomial)
    return poly_utils.prettyprint(self)
end

schema.degree = function(self : types.Polynomial)
    local trimmed = self:trim()
    return trimmed.coef.Shape[1] - 1
end

schema.cutdeg = function(self : types.Polynomial,degree : number)
    if degree > self:degree() then
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

schema.deriv = function(self : types.Polynomial)
    local result_coeff : types.ndArray<number> = self.coef:copy()["2:"]

    for i = 1,#result_coeff do
        result_coeff[i] *= i
    end

    return interface.new(result_coeff:toflatlist(),table.clone(self.domain),table.clone(self.window),self.symbol)
end

schema.integ = function(self : types.Polynomial)
    local data = self.coef:toflatlist()

    for i = 1,#data do
        data[i] /= (i)
    end

    table.insert(data,1,0)

    return interface.new(data,table.clone(self.domain),table.clone(self.window),self.symbol)
end

schema.trim = function(self : types.Polynomial,tol : number)
    tol = tol or 0

    local data = self.coef:toflatlist()
    for i = self.coef.Shape[1],1,-1 do
        if self.coef.Buffer[i] > tol then break end
        table.remove(self.coef.Buffer,i)
    end

    local result = self:copy()
    result.coef = ndArray(data, {#data}, {1}, 0, "number")
    
    return result
end

schema.companion =function(self : types.Polynomial)
    local degree = self:degree()

    if degree < 2 then
        return exceptions.FormatException("Poly", "polynomial must have degree")
    end

    local companion_matrix = ndArray(table.create(degree * degree,0), {degree,degree}, {degree,1}, 0, "number")

    for i = 1,degree - 1 do
        companion_matrix[i + 1][i] = 1
    end

    local leading_coeff = self.coef.Buffer[degree + 1]

    for i = 1,degree do
        companion_matrix[i][degree] = -self.coef.Buffer[i] / leading_coeff
    end

    return companion_matrix
end

schema.roots = function(self : types.Polynomial)
    local degree = self:degree()
    if degree == 1 then
        return ndArray({-self.coef.Buffer[1] / self.coef.Buffer[2]}, {}, {}, 0, "number")
    end

    if degree == 2 then
        local a = self.coef.Buffer[3]
        local b = self.coef.Buffer[2]
        local c = self.coef.Buffer[1]
        return ndArray({
            (-b - math.sqrt((b^2) - 4 * a * c)) / (2 * a),
            (-b + math.sqrt((b^2) - 4 * a * c)) / (2 * a)
        }, {2}, {1}, 0, "number")
    end

    return linear_algebra.eigenval(self:companion())
end




return interface
