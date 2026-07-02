local types = require("../types")
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
    local format_base = "%d+"

    for i = 2,self.coef.Shape[1] do
        format_base ..= "%d" .. self.symbol .. (i == 2 and "" or (i - 1)).. "+"
    end

    format_base = format_base:sub(1,#format_base - 1)

    for init,translated in superscript_mapping do
        format_base = format_base:gsub(init, translated)
    end

    format_base = format_base:gsub("+"," + ")
    
    return format_base:format(table.unpack(self.coef:toflatlist()))
end


return module