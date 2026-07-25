--!strict
local evaluation = require("@self/evaluation")
local types = require("@self/types")

local format = require("@self/format")

local module = {
	groups = {},
}

local misc_group: string = "misc"

module.groups[misc_group] = {
	baseline = nil,
	cases = {},
}

export type bench_result = types.bench_result

function module.bench(name: string, callback: types.bench_callback, properties: types.bench_properties?)
	local bench_case: types.bench_case = {
		name = name,
		callback = callback,
	}

	if properties == nil then
		table.insert(module.groups[misc_group].cases, bench_case)
		return
	end

	if properties.ignore == true then return end

	local group_name: string = properties.group or misc_group

	if module.groups[group_name] == nil then module.groups[group_name] = {
		baseline = nil,
		cases = {},
	} end

	local group: types.group = module.groups[group_name] :: types.group

	if properties.baseline == true then
		group.baseline = bench_case
	else
		table.insert(group.cases, bench_case)
	end
end

function module.print_result()
	local result: { [string]: types.bench_result } = {}
	local count = 0
	local indent = "    "
	local indent2 = "        "

	for name, group in module.groups do
		result[name] = evaluation.evaluate_group(group :: types.group)
		count += 1
	end

	for name, entry in result do
		if count > 1 then print(`{name}:`) end

		format.pretty_print(entry)

		local group: types.group = module.groups[name] :: types.group
		if group.baseline ~= nil then
			print(`summary\n{indent}{"\x1b[1m" .. format.set_color(group.baseline.name, "blue")}`)
			local baseline_index: number = table.find(entry.benchmark, group.baseline.name) :: number
			local base_time = entry.mean[baseline_index]

			for i = 2, #entry.mean do
				local mean_time = entry.mean[i]
				local baseline_is_faster = base_time < mean_time

				local ratio = baseline_is_faster and base_time / mean_time or mean_time / base_time

				local formatted_ratio = ("%.2f"):format(ratio)
				formatted_ratio = format.set_color(formatted_ratio, (baseline_is_faster and "green" or "red"))

				local comparison = if baseline_is_faster then "faster" else "slower"
				local formatted_name = "\x1b[1m" .. format.set_color(entry.benchmark[i], "blue")

				print(`{indent2}{formatted_ratio}x {comparison} than {formatted_name}`)
			end
		end
	end

	return result
end

function module.evaluate_as_csv()
	local result = {}

	for name, group in module.groups do
		result[name] = evaluation.evaluate_group(group :: types.group)
	end

	return format.toCSV(result)
end

function module.set_printoptions(options: {
	column_seperator: string,
	row_seperator: string,
	ANSI: boolean,
})
	format.seperator = options.column_seperator or format.seperator
	format.row_seperator = options.row_seperator or format.row_seperator

	format.ANSI = if options.ANSI ~= nil then options.ANSI else format.ANSI
end

return module
