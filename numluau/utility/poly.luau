--!strict
local types = require("../types")
local exceptions = require("../Exceptions")

local linear_algebra = require("../math/lin_algebra")

export type printstyle = "ascii" | "unicode"

local module = {}
module.precision = 8
module.suppress = false
module.printstyle = "ascii" :: printstyle

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

local format_term = function(value : number,power : number,symbol : string) : string
    local value_string : string
    if module.suppress == true then
        value_string = string.format(`%.{module.precision}f`,value):gsub("%.?0+$", "") 
    else
        value_string = string.format(`%.{module.precision}g`,value)
    end

    if power == 0 then
        return value_string
    end

    if power == 1 then
        return `{value_string}{symbol}`
    end

    local power_formatted = tostring(power)
    if module.printstyle == "ascii" then
        power_formatted = "^" .. power_formatted
    elseif module.printstyle == "unicode" then
        power_formatted = power_formatted:gsub("%d",superscript_mapping)
    end

    local format = `%s{symbol}{power_formatted}`
    local result = string.format(format,value_string)

    return result
end

module.prettyprint = function(self : types.Polynomial) : string
    local result : string = ""

    local coefs : {number} = self.coef:toflatlist()

    for i,coef : number in ipairs(coefs) do
        local sign = if coef >= 0 then " + " else " - " 

        if i == 1 then
            sign = coef >= 0 and "" or "-"
        end

        result ..= sign .. format_term(math.abs(coef), i - 1, self.symbol)
    end

    return result
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

    local coef = linear_algebra.lstsq(x,y,degree)

    return coef
end


return module