local types = require("../types")
local ndArray = require("../ndarray/ndarray")

local poly_utils = require("../utility/poly")
local table_utils = require("../utility/table")
local linear_algebra = require("../math/lin_algebra")

local exceptions = require("../Exceptions")

local interface = {}
local schema = {}

local meta = {__index = schema}

interface.new = function(coef : {number} | types.ndArray<number>,domain : {number}?,window : {number}?,symbol : string?) : types.Polynomial
    if coef.type ~= nil and coef.type == "ndArray" then
        coef = coef.Buffer
    end
    
    local polynomial = {}

    polynomial.coef = ndArray(coef, {#coef}, {1}, 0, "number")
    polynomial.domain = domain or {-1,1}
    polynomial.window = window or {-1,1}
    polynomial.symbol = symbol or 'x'

    return setmetatable(polynomial, meta) :: types.Polynomial
end

meta.__call = function(self : types.Polynomial, ... : types.ndArray<number> | number)
    local args = {...}

    local window_range = self.window[2] - self.window[1]
    local domain_range = self.domain[2] - self.domain[1] 

    if #args == 1 then
        local value = args[1]

        if typeof(value) == "number" then
            local mapped_value = self.window[1] + (window_range * (value - self.domain[1]) / domain_range)
            local result = 0
            for i,v in self.coef do
                result += (i > 0 and (mapped_value ^ (i - 1)) or 1) * v
            end

            return result
        end

        local data = {}

        for i,val in value do
            local mapped_value = self.window[1] + (window_range * (value - self.domain[1]) / domain_range)
            local result = 0
            for i,v in self.coef do
                result += (i > 0 and (mapped_value ^ (i - 1)) or 1) * v
            end

            data[i] = result
        end

        return ndArray(data, table.clone(value.Shape), table.clone(value.Strides), 0, "number")
    end

    local arg_ndarray = ndArray(args, {#args}, {1}, 0, "number")

    return meta.__call(self,arg_ndarray)
end

meta.__tostring = function(self : types.Polynomial)
    return poly_utils.prettyprint(self)
end

meta.__add = function(self : types.Polynomial,other : types.Polynomial | number)
    if typeof(other) == "number" then
        local copy = self:copy()
        copy.coef.Buffer[1] += other

        return copy
    end

    if typeof(self) == "number" then
        local copy = other:copy()
        copy.coef.Buffer[1] += self

        return copy
    end

    if self.symbol ~= other.symbol then
        exceptions.FormatException("Poly", "Cannot add polynomials with different symbols")
    end

    local max_size = math.max(self.coef.Shape[1],other.coef.Shape[1])

    local broad_data_A = table_utils.fillup(self.coef.Buffer, 0, max_size)
    local broad_data_B = table_utils.fillup(other.coef.Buffer, 0, max_size)

    local coef_A = ndArray(broad_data_A, {max_size}, {1}, 0, "number")
    local coef_B = ndArray(broad_data_B, {max_size}, {1}, 0, "number")

    return interface.new(coef_A + coef_B,table.clone(self.domain),table.clone(self.window),self.symbol)
end

meta.__sub = function(self : types.Polynomial,other : types.Polynomial | number)
    if typeof(other) == "number" then
        local copy = self:copy()
        copy.coef.Buffer[1] -= other

        return copy
    end

    if typeof(self) == "number" then
        local copy = other:copy()
        copy.coef.Buffer[1] = self - copy.coef.Buffer[1]
        
        return copy
    end

    if self.symbol ~= other.symbol then
        exceptions.FormatException("Poly", "Cannot subtract polynomials with different symbols")
    end

    local max_size = math.max(self.coef.Shape[1],other.coef.Shape[1])

    local broad_data_A = table_utils.fillup(self.coef.Buffer, 0, max_size)
    local broad_data_B = table_utils.fillup(other.coef.Buffer, 0, max_size)

    local coef_A = ndArray(broad_data_A, {max_size}, {1}, 0, "number")
    local coef_B = ndArray(broad_data_B, {max_size}, {1}, 0, "number")

    return interface.new(coef_A - coef_B,table.clone(self.domain),table.clone(self.window),self.symbol)
end

meta.__mul = function(self : types.Polynomial,other : types.Polynomial | number)
    if typeof(other) == "number" then
        local copy = self:copy()
        for i,v in copy.coef do
            copy.coef[i] = v * other
        end

        return copy
    end

    if typeof(self) == "number" then
        local copy = other:copy()
        for i,v in copy.coef do
            copy.coef[i] = v * self
        end

        return copy
    end

    if self.symbol ~= other.symbol then
        exceptions.FormatException("Poly", "Cannot multiply polynomials with different symbols")
    end

    local coef_A = self.coef.Buffer
    local coef_B = other.coef.Buffer

    local length_A = #coef_A
    local length_B = #coef_B

    if length_A == 0 or length_B == 0 then
        return interface.new({0},table.clone(self.domain),table.clone(self.window),self.symbol)
    end

    local result_length = length_A + length_B - 1
    local result_coef = table.create(result_length,0)

    for i = 1,length_A  do

        if coef_A[i] == 0 then continue end

        for j = 1,length_B do
            local target_index = i + j - 1
            result_coef[target_index] += coef_A[i] * coef_B[j]
        end
    end

    for i = #result_coef,1,-1 do
        if result_coef[i] > 0 then break end
        table.remove(result_coef,i)
    end

    return interface.new(result_coef,table.clone(self.domain),table.clone(self.window),self.symbol)
end

meta.__idiv = function(self : types.Polynomial,other : types.Polynomial | number)
    if typeof(other) == "number" then
        local copy = self:copy()
        for i,v in copy.coef do
            copy.coef[i] = v // other
        end

        return copy
    end

    if typeof(self) == "number" then
        local copy = other:copy()
        for i,v in copy.coef do
            copy.coef[i] = self // v
        end

        return copy
    end

    if self.symbol ~= other.symbol then
        exceptions.FormatException("Poly", "Cannot divide polynomials with different symbols")
    end

    local coef_A = self.coef.Buffer
    local coef_B = other.coef.Buffer

    local remainder_coef = table.move(coef_A, 1, #coef_A, 1, table.create(#coef_A))
    local divisor_coef = coef_B

    local dividend_degree = #remainder_coef - 1
    local divisor_degree = #divisor_coef - 1

    if divisor_degree == 0 and divisor_coef[1] == 0 then
        exceptions.FormatException("Value", "cannot by divide by zero polynomial")
    end

    if dividend_degree < divisor_degree then
        return interface.new({0}, table.clone(self.domain), table.clone(self.window), self.symbol)
    end

    local quotient_degree = dividend_degree - divisor_degree
    local quotient_coef = table.create(quotient_degree + 1,0)

    for i = quotient_degree,0,-1 do
        local remainder_index = i + divisor_degree + 1
        local divisor_index = divisor_degree + 1

        local lead_coef = remainder_coef[remainder_index] / divisor_coef[divisor_index]
        quotient_coef[i + 1] = lead_coef

        for j = 0,divisor_degree do
            local target_remainder_index = i + j + 1
            remainder_coef[target_remainder_index] -= lead_coef * divisor_coef[j + 1]
        end
    end

    return interface.new(quotient_coef,table.clone(self.domain),table.clone(self.window),self.symbol)
end

meta.__div = function(self : types.Polynomial,other : types.Polynomial | number)
    if typeof(other) == "number" then
        local copy = self:copy()
        for i,v in copy.coef do
            copy.coef[i] = v // other
        end

        return copy
    end

    if typeof(self) == "number" then
        local copy = other:copy()
        for i,v in copy.coef do
            copy.coef[i] = self // v
        end

        return copy
    end

    if self.symbol ~= other.symbol then
        exceptions.FormatException("Poly", "Cannot multiply polynomials with different symbols")
    end

    exceptions.FormatWarn("Poly","use // operator for polynomial division")
    return self // other
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

        local discriminant = (b^2) - 4 * a * c

        return ndArray({
            (-b - math.sqrt(discriminant)) / (2 * a),
            (-b + math.sqrt(discriminant)) / (2 * a)
        }, {2}, {1}, 0, "number")
    end

    return linear_algebra.eigenval(self:companion())
end

return interface
