return {
    Array = require("@self/ndarray"),
    Slice = function(start,stop,step)
        return {
            start = start,
            stop = stop,
            step = step or 1,
            __slice = true
        }
    end
}