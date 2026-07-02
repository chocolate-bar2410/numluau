local module = {}

local RESET = "\x1B[0m"
local RED = "\x1B[31m"

local ExceptionTypes = {
    ["Broadcasting"] = "Error with broadcasting: %s",
    ["Array"] = "Error when handling array: %s",
    ["Malformed"] = "Malformed Array: %s",

    ["Axis"] = "Axis supplied was invalid",
    ["LinAlg"] = "Error with linear algebra: %s",
    ["Random"] = "Error with generating random number: %s"
}

module.FormatException = function(ExceptionType : string,Message : string)
    local Tag = ExceptionTypes[ExceptionType]

    error(RED .. string.format(Tag,Message) .. RESET)
end

module.Exception = function(ExceptionType : string)
    local Tag = ExceptionTypes[ExceptionType]

    error(RED .. Tag .. RESET)
end

return module