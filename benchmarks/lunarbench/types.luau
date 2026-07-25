export type bench_result = {
	benchmark: { string },
	throughput: { number },
	min: { number },
	max: { number },
	mean: { number },
	p75: { number },
	p99: { number },
	p995: { number },
}

export type bench_case = {
	name: string,
	callback: bench_callback,
}

export type group = {
	baseline: bench_case?,
	cases: { bench_case },
}

export type bench_context = {
	start: () -> (),
	stop: () -> (),
}

export type bench_callback = (bench_context: bench_context) -> ()
export type bench_properties = {
	baseline: boolean,
	group: string,
	ignore: boolean,
}

return nil
