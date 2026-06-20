--!strict
-- a small framework for our unit tests inspired by junit
local module = {}

local tests : {test} = {} 

type test = {
    message : string,
    result : boolean,
    error_message : unknown,
}

local table_equals = function<T>(A : {T},B : {T})
    if #A ~= #B then return false end

    for i = 1,#A do
        if A[i] ~= B[i] then return false end
    end

    return true
end

local tab_string = function<T>(A : {T})
    return string.format("{%s}",table.concat(A,","))
end

module.Test = function(message : string,callback : () -> ())
    local result : boolean, error_msg : unknown = pcall(callback)

    table.insert(tests,{
        message = message,
        result = result,
        error_message = error_msg
    })
end

module.PrintResults = function()
    local all_passed = true
    local tests_passed = 0

    local result = ""

    for _,test in tests do
        all_passed = test.result and all_passed 
        
        if test.result then
            result ..= ("[PASS]: %q\n"):format(test.message)
            tests_passed += 1
        else
            local error_message : string = test.error_message :: string
            error_message = string.match(error_message, ":%d+: (.*)") :: string
            result ..= ("[FAIL]: %q \n        %s\n"):format(test.message,error_message)
        end
    end

    if all_passed then
        print(result .. "\nall tests passed")
    else
        print(result .. ("\n%d/%d tests passed"):format(tests_passed,#tests))
    end

end

module.AssertEquals = function(A,B)
    if type(A) == "table" and type(A) == type(B) then
        if table_equals(A,B) then return end

        error(("%s and %s aren't equal"):format(tab_string(A),tab_string(B)))
    else
        if A == B then return end

        error(("%s and %s aren't equal"):format(tostring(A),tostring(B)))
    end    
end

module.AssertNotEquals = function(A,B)
    if type(A) == "table" and type(A) == type(B) then
        if not table_equals(A,B) then return end

        error(("%s and %s are equal"):format(tab_string(A),tab_string(B)))
    else
        if A ~= B then return end

        error(("%s and %s are equal"):format(tostring(A),tostring(B)))
    end
end

module.AssertTrue = function(Condition)
    if Condition then return end
    error("Condition is false")
end

module.AssertFalse = function(Condition)
    if not Condition then return end
    error("Condition is true")
end

return module