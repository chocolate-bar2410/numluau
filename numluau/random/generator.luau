local types = require("../types")
local ndArray = require("../ndarray/ndarray")

local exceptions = require("../exceptions")
local ndarray_utils = require("../ndarray/ndarray_utils")

local zig_lookup = require("./zigguratt")

local interface = {}
local schema = {}
local meta = {__index = schema}

-- luau numbers can technically hold up to 2^53 bits
-- but RNG algorithms rely on 32 bit outputs
local RNG_MAX = 2^32 - 1 

interface.new = function(bit_generator : () -> number)
    local generator = {}
    generator.BitGenerator = bit_generator

    return setmetatable(generator, meta)
end

schema.rand = function(self : types.Generator,... : number)
    local shape = {...} or {1}
    
    local valid_shape,err_msg = ndarray_utils.VerifyShape(shape)

    if not valid_shape then
        exceptions.FormatException("Array", err_msg)
    end

    local size = ndarray_utils.ComputeSize(shape)

    local data = table.create(size,0)
    local strides = ndarray_utils.ComputeStrides(shape)

    for i = 1,size do
        data[i] = self.BitGenerator() / (RNG_MAX)
    end

    return ndArray(data, shape, strides, 0, "number")
end

local ziggurat = function(BitGenerator : () -> number)
    local layers = 128
    local r = 3.442619855899  -- right edge
    while true do
        local layer = math.random(1,layers)

        local x_i = zig_lookup.x[layer]
        local k_i = zig_lookup.k[layer]

        local u = BitGenerator() / (RNG_MAX)

        local x_value = u * x_i

        if u < k_i then
            local value = BitGenerator() / (RNG_MAX) > 0.5 and x_value or -x_value
            return value
        end

        -- slow path

        -- top layer uses tail sampling
        if layer == 1 then
            local x_tail
            local y_tail

            repeat
                x_tail = -math.log(BitGenerator() / (RNG_MAX)) / r
                y_tail = -math.log(BitGenerator() / (RNG_MAX))
            until y_tail + y_tail > x_tail * x_tail

            local value = BitGenerator() / (RNG_MAX) > 0.5 and r + x_tail or -(r + x_tail)
            return value
        end
        
        -- rejection test
        -- sees if y falls under the curve exp(-0.5x²)
        local y_value = zig_lookup.f[layer] + (zig_lookup.f[layer + 1] - zig_lookup.f[layer]) * BitGenerator() / (RNG_MAX)

        if y_value >= math.exp(-0.5 * x_value ^ 2) then continue end
        local value = BitGenerator() / (RNG_MAX) > 0.5 and x_value or -x_value
        return value
    end
end

schema.normal = function(self : types.Generator,mean : number,std_dev : number,shape : {number})
    shape = shape or {1}

    local valid_shape,err_msg = ndarray_utils.VerifyShape(shape)

    if not valid_shape then
        exceptions.FormatException("Array", err_msg)
    end

    local size = ndarray_utils.ComputeSize(shape)

    local data = table.create(size,0)
    local strides = ndarray_utils.ComputeStrides(shape)
    
    -- using zigguratt algorithm

    for i = 1,size do
        data[i] = mean + std_dev * ziggurat(self.BitGenerator)
    end

    return ndArray(data, shape, strides, 0, "number")
end

return interface