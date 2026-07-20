local types = require("./types")
local generator = require("@self/generator")
local prng = require("@self/prng")

local table_utils = require("./utility/table")

local module = {}

--- the random submodule of numluau.
---@class random

--- Constructs a new `Generator` object using the default bit generator (PCGXSH) with the seed provided.
---@within random
---@method default_rng
---@param seed number
---@return Generator
module.default_rng = function(seed: number): types.Generator
	return generator.new(prng.PCGXSH(seed))
end

module.generator = generator.new

type bit_generator = (seed: number) -> number

return table_utils.merge(module, prng) :: {
	default_rng: (seed: number) -> types.Generator,
	generator: (bit_generator) -> types.Generator,
	XOSHIRO128: () -> bit_generator,
	SFC32: () -> bit_generator,
	Philox: () -> bit_generator,
	JSF32: () -> bit_generator,
	PCGXSH: () -> bit_generator,
}
