local module = {}

local ExceptionTypes = {
    ["Broadcasting"] = "Error with broadcasting: %s",
    ["Array"] = "Error when handling array: %s",
    ["Malformed"] = "Malformed Array: %s"
}

module.Exception = function(ExceptionType : string,Message : string)
    local Tag = ExceptionTypes[ExceptionType]

    error(string.format(Tag,Message))
end

return module