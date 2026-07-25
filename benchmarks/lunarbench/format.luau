--!strict
local types = require("./types")
local module = {}

module.seperator = " | "
module.row_seperator = "-"
module.ANSI = true

local ANSI: { [string]: string } = {
	red = "\x1b[91m",
	green = "\x1b[92m",
	yellow = "\x1b[93m",
	blue = "\x1b[96m",
	magenta = "\x1b[95m",
	reset = "\x1b[0m",
}

module.set_color = function(text: string, colour: string): string
	if module.ANSI == false then
		return text
	end
	return ANSI[colour] .. text .. ANSI.reset
end

local remove_ansi = function(text: string)
	return text:gsub("\x1b%[[0-9;]*m", "")
end

local format_duration = function(duration: number): string

	if duration < 0.001 then
		return string.format("%.1f", duration * 1e6) .. "ns"
	elseif duration < 1 then
		return string.format("%.1f", duration * 1000) .. "μs"
	elseif duration >= 1000 then
		return string.format("%.1f", duration / 1000) .. "sec"
	end

	return string.format("%.1f", duration) .. "ms"
end

local pad_string_table = function(string_table: { string }): number
	local max_width = -1

	for i = 1, #string_table do

		local raw_value = remove_ansi(string_table[i])
		local length: number = utf8.len(raw_value) :: number
		max_width = math.max(max_width, length)
	end

	for i = 1, #string_table do
		local raw_value = remove_ansi(string_table[i])
		local length: number = utf8.len(raw_value) :: number
		local padding = max_width - length

		string_table[i] = string.rep(" ", padding) .. string_table[i]
	end

	return max_width
end

type column = {
	header: string,
	values: { string },
}

module.pretty_print = function(result: types.bench_result)
	local output: string = ""

	local columns: { column } = {
		{
			header = "benchmark",
			values = { "benchmark" },
		},
		{
			header = "time/iter (avg)",
			values = { "time/iter (avg)" },
		},
		{
			header = "iter/s",
			values = { "iter/s" },
		},
		{
			header = "(min .. max)",
			values = { "(min .. max)" },
		},
		{
			header = "p75",
			values = { "p75" },
		},
		{
			header = "p99",
			values = { "p99" },
		},
		{
			header = "p995",
			values = { "p995" },
		},
	}

	for i = 1, #result.benchmark do
		columns[1].values[i + 1] = result.benchmark[i]
		columns[2].values[i + 1] = module.set_color(format_duration(result.mean[i]), "yellow")
		columns[3].values[i + 1] = string.format("%.1f", result.throughput[i])
		columns[4].values[i + 1] = `({module.set_color(format_duration(result.min[i]), "blue")} .. {module.set_color(
			format_duration(result.max[i]),
			"magenta"
		)})`
		columns[5].values[i + 1] = module.set_color(format_duration(result.p75[i]), "magenta")
		columns[6].values[i + 1] = module.set_color(format_duration(result.p99[i]), "magenta")
		columns[7].values[i + 1] = module.set_color(format_duration(result.p995[i]), "magenta")
	end

	for _, column in columns do
		local width = pad_string_table(column.values)

		local seperation = string.rep(module.row_seperator, width)
		table.insert(column.values, 2, seperation)
	end

	for row = 1, #columns[1].values do
		output ..= module.seperator

		for _, column in columns do
			output ..= column.values[row] .. module.seperator
		end

		output ..= "\n"
	end

	print(output)

end

module.toCSV = function(result: { [string]: types.bench_result })

	local output = "group,benchmark,average,throughput,min,max,p75,p99,p995\r\n"

	for group_name, group in result do
		for i = 1, #group.benchmark do
			local processed = {
				`"{group_name}"`,
				group.benchmark[i],
				group.mean[i],
				group.throughput[i],
				group.min[i],
				group.max[i],
				group.p75[i],
				group.p99[i],
				group.p995[i],
			}

			output ..= table.concat(processed, ",") .. "\r\n"
		end
	end

	return output
end

return module
