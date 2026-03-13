local module = {}

local ExceptionTypes = {
    ["Broadcasting"] = "Error with broadcasting: %s",
    ["Array"] = "Error when handling array: %s",
    ["Malformed"] = "Malformed Array: %s",

    ["Axis"] = "Axis supplied was invalid",
}

module.FormatException = function(ExceptionType : string,Message : string)
    local Tag = ExceptionTypes[ExceptionType]

    error(string.format(Tag,Message))
end

module.Exception = function(ExceptionType : string)
    local Tag = ExceptionTypes[ExceptionType]

    error(Tag)
end

return module