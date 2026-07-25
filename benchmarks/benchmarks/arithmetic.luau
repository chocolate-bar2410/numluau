local lunarbench = require("../lunarbench")
local numluau = require("../../numluau")

local A = numluau.array(table.create(60000, 60000))
local B = numluau.array(table.create(60000, 60000))

lunarbench.bench("ndarray add", function(bench_context)
	local C = A + B
end, { group = "arithmetic" })

lunarbench.bench("ndarray subtract", function(bench_context)
	local C = A - B
end, { group = "arithmetic" })

lunarbench.bench("ndarray multiply", function(bench_context)
	local C = A * B
end, { group = "arithmetic" })

lunarbench.bench("ndarray divide", function(bench_context)
	local C = A / B
end, { group = "arithmetic" })

lunarbench.bench("ndarray int divide", function(bench_context)
	local C = A // B
end, { group = "arithmetic" })

lunarbench.bench("ndarray exponent", function(bench_context)
	local C = A ^ B
end, { group = "arithmetic" })

lunarbench.bench("ndarray modulo", function(bench_context)
	local C = A % B
end, { group = "arithmetic" })

return nil
