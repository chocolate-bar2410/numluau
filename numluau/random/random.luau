local types = require("../types")
local generator = require("./generator")
local prng = require("./prng")

local Merge = function(... : {})
    local Result = {}

    for _,tab in {...} do
        for i,v in tab do
            Result[i] = v
        end
    end

    return Result
end

local module = {}

module.default_rng = function(seed : number) : types.Generator
    return generator.new(seed, prng.PCGXSH(seed))
end

module.generator = generator.new

type bit_generator = (seed : number) -> number

return Merge(module,prng) :: {
    default_rng : (seed : number) -> types.Generator,
    generator : (bit_generator) -> types.Generator,
    XOSHIRO128 : () -> bit_generator,
    SFC32 : () -> bit_generator,
    Philox : () -> bit_generator,
    JSF32 : () -> bit_generator,
    PCGXSH : () -> bit_generator,
}