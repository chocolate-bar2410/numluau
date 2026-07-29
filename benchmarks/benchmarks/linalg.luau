local lunarbench = require("../lunarbench")
local numluau = require("../../numluau")

lunarbench.bench("matmul", function(bench_context)
	local A = numluau.ones(50, 50)
	local B = numluau.ones(50, 50)

	bench_context.start()
	numluau.linalg.matmul(A, B)
end, { group = "linear algebra", ignore = false })

lunarbench.bench("dot", function(bench_context)
	local A = numluau.ones(50)
	local B = numluau.ones(50)

	bench_context.start()
	numluau.linalg.dot(A, B)
end, { group = "linear algebra", ignore = false })

lunarbench.bench("cross", function(bench_context)
	local A = numluau.ones(3)
	local B = numluau.ones(3)

	bench_context.start()
	numluau.linalg.cross(A, B)
end, { group = "linear algebra", ignore = false })

lunarbench.bench("eigval", function(bench_context)
	local A = numluau.ones(10, 10):eye()

	bench_context.start()
	numluau.linalg.eigenval(A)
end, { group = "linear algebra", ignore = false })

lunarbench.bench("eig", function(bench_context)
	local A = numluau.ones(10, 10):eye()

	bench_context.start()
	numluau.linalg.eig(A)
end, { group = "linear algebra", ignore = false })

lunarbench.bench("qr", function(bench_context)
	local A = numluau.ones(20, 20)
	bench_context.start()
	numluau.linalg.qr(A)
end, { group = "linear algebra", ignore = false })

lunarbench.bench("lu", function(bench_context)
	local A = numluau.ones(30, 30)
	bench_context.start()
	numluau.linalg.lu(A)
end, { group = "linear algebra", ignore = false })

lunarbench.bench("svd", function(bench_context)
	local A = numluau.ones(30, 30)
	bench_context.start()
	numluau.linalg.svd(A)
end, { group = "linear algebra", ignore = true })

lunarbench.bench("norm l1", function(bench_context)
	local A = numluau.ones(1000, 1000)
	bench_context.start()
	numluau.linalg.norm(A, 0, 1)
end, { group = "linear algebra", ignore = false })

lunarbench.bench("norm l2", function(bench_context)
	local A = numluau.ones(1000, 1000)
	bench_context.start()
	numluau.linalg.norm(A, 0, 2)
end, { group = "linear algebra", ignore = false })

return nil
