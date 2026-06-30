local types = require("../types")
local generator = require("./generator")
local prng = require("./prng")
local module = {}

module.default_rng = function(seed : number) : types.Generator
    return generator.new(seed, prng.PCGXSH(seed))
end

module.generator = generator.new


return module