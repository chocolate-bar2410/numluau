-- benchmarking script using lunar bench
local lunarbench = require("./lunarbench")

--require("./benchmarks/arithmetic")
require("./benchmarks/linalg")

lunarbench.print_result()
