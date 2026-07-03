local types = require("../types")
local math_utils = require("../math/math_utils")
local exceptions = require("../Exceptions")

local constructors = require("../ndarray/constructors")

local linear_algebra = require("../math/lin_algebra")

local module = {}

local superscript_mapping = {
    ["0"] = "⁰",
    ["1"] = "¹",
    ["2"] = "²",
    ["3"] = "³",
    ["4"] = "⁴",
    ["5"] = "⁵",
    ["6"] = "⁶",
    ["7"] = "⁷",
    ["8"] = "⁸",
    ["9"] = "⁹"
}

module.prettyprint = function(self : types.Polynomial)
    local result = ""

    local size = self.coef.Shape[1]

    if size == 1 then
        return self.coef.Buffer[1]
    end

    for i,number in self.coef do

        if i - 1 == 0 then
            result ..= "%g"
            continue
        end

        result ..= number < 0 and "-" or "+"
        result ..= "%g" .. "∙" .. self.symbol .. i - 1
    end

    result = result:gsub("+"," + ")
    result = result:gsub("-"," - ")

    result = result:gsub("%d",superscript_mapping)

    return result:format(table.unpack(math_utils.abs(self.coef):toflatlist()))
end

module.fit = function(x : types.ndArray<number>,y : types.ndArray<number>,degree : number)
    if typeof(degree) ~= "number" then
        exceptions.FormatException("Type", "polyfit degree must be a number")
    elseif degree <= 0 then
        exceptions.FormatException("Value", "polyfit degree must be greater than 0")
    elseif x.ndim ~= 1 then
        exceptions.FormatException("Value", "polyfit x parameter must have ndim = 1")
    elseif y.ndim ~= 1 then
        exceptions.FormatException("Value", "polyfit y parameter must have ndim = 1")
    elseif x.Shape[1] ~= y.Shape[1] then
        exceptions.FormatException("Value", "polyfit x & y parameters must have the same length")
    end

    local order = degree + 1

    local vandemonde = constructors.vander(x,order)

    local coef = linear_algebra.solve(vandemonde, y)

    print(coef)
end


return module