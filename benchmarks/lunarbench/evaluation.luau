--!strict
local types = require("./types")
local module = {}

module.create_bench_result = function(group: types.group): types.bench_result
	local bench_result: types.bench_result = {
		benchmark = {},
		throughput = {},
		min = {},
		max = {},
		mean = {},
		p75 = {},
		p99 = {},
		p995 = {},
	}
	if group.baseline ~= nil then table.insert(bench_result.benchmark, group.baseline.name) end

	for i = 1, #group.cases do
		table.insert(bench_result.benchmark, group.cases[i].name)
	end

	return bench_result
end

local compute_percentile = function(times: { number }, percentile: number)
	local index = 1 + (percentile / 100) * (#times - 1)

	local lower = math.min(math.floor(index), #times)
	local upper = math.min(math.ceil(index), #times)

	if lower == upper then return times[lower] end

	local weight = index - lower
	return math.lerp(times[lower], times[upper], weight)
end

local min_target = 0.005

local probe = function(callback, bench_context: types.bench_context)
	local probe_amount = 1
	local elapsed = 0

	while elapsed < min_target do
		local start = os.clock()
		for i = 1, probe_amount do
			callback(bench_context)
		end

		elapsed = os.clock() - start
		if elapsed < min_target then
			probe_amount *= math.max(2, math.ceil(min_target / elapsed))
		end
	end

	return probe_amount, elapsed
end

module.evaluate_case = function(case: types.bench_case, result: types.bench_result)
	local start = 0
	local stop = 0

	print(case.name)
	print("probing")

	local bench_context: types.bench_context = {
		start = function()
			start = os.clock()
		end,
		stop = function()
			stop = os.clock()
		end,
	}

	local probe_amount, probe_time = probe(case.callback, bench_context)

	probe_time = math.max(probe_time, 1e-9)

	local iterations = math.ceil(probe_amount * (min_target / probe_time))
	iterations = math.clamp(iterations, 50, 1e6)

	local times = {}

	local throughput: number = 0
	local min: number = math.huge
	local max: number = -math.huge
	local total: number = 0

	print("started")

	for i = 1, iterations do
		print(`iterations {i}/{iterations}`)
		start = os.clock()
		stop = 0

		case.callback(bench_context)

		if stop == 0 then stop = os.clock() end

		local timetaken = stop - start
		min = math.min(min, timetaken)
		max = math.max(max, timetaken)

		total += timetaken

		times[i] = timetaken
	end

	throughput = iterations / total
	local mean: number = total / iterations

	table.sort(times)

	local p75: number = compute_percentile(times, 75)
	local p99: number = compute_percentile(times, 99)
	local p995: number = compute_percentile(times, 99.5)

	table.insert(result.throughput, throughput)
	table.insert(result.min, min)
	table.insert(result.max, max)
	table.insert(result.mean, mean)
	table.insert(result.p75, p75)
	table.insert(result.p99, p99)
	table.insert(result.p995, p995)
end

module.evaluate_group = function(group: types.group): types.bench_result
	local result = module.create_bench_result(group)

	if group.baseline ~= nil then module.evaluate_case(group.baseline, result) end

	for i = 1, #group.cases do
		module.evaluate_case(group.cases[i], result)
	end

	return result
end

return module
