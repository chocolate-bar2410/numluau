local module = {}

local RESET = "\x1B[0m"
local RED = "\x1B[31m"
local ORANGE = "\x1B[38;2;255;165m"

local ExceptionTypes = {
    ["Broadcasting"] = "Error with broadcasting: %s",
    ["Array"] = "Error when handling array: %s",
    ["Malformed"] = "Malformed Array: %s",

    ["Axis"] = "Axis supplied was invalid",
    ["LinAlg"] = "Error with linear algebra: %s",
    ["Random"] = "Error with generating random number: %s",
    ["Poly"] = "Polynomial error: %s",
    ["Type"] = "Type error: %s",
    ["Value"] = "Value error: %s",
}

type exception_type = "Broadcasting" | "Array" | "Malformed" | "Axis" | "LinAlg" | "Random" | "Poly" | "Type" | "Value"

module.FormatException = function(ExceptionType : exception_type,Message : string)
    local Tag = ExceptionTypes[ExceptionType]

    error(RED .. string.format(Tag,Message) .. RESET)
end

module.Exception = function(ExceptionType : exception_type)
    local Tag = ExceptionTypes[ExceptionType]

    error(RED .. Tag .. RESET)
end

module.FormatWarn = function(ExceptionType : exception_type,Message : string)
    local Tag = ExceptionTypes[ExceptionType]:gsub("Error","Warning"):gsub("error","warning")

    print(ORANGE .. string.format(Tag,Message) .. RESET)
end

return module