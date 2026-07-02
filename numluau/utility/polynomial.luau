local types = require("../types")
local math_utils = require("../math/math_utils")
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


return module