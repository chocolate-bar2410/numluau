-- benchmarking script using lunar bench
local lunarbench = require("./lunarbench")

--require("./benchmarks/arithmetic")
require("./benchmarks/linalg")

lunarbench.set_printoptions({ progress_bar = true })

lunarbench.print_result()
