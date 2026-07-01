local types = require("../types")
local ndArray = require("../ndarray/ndarray")

local exceptions = require("../exceptions")
local ndarray_utils = require("../utility/ndarray")

local zig_normal = require("./zig_normal")
local zig_exp = require("./zig_exp")

local math_util = require("../utility/math")

local interface = {}
local schema = {}
local meta = {__index = schema}

-- luau numbers can technically hold up to 2^53 bits
-- but RNG algorithms rely on 32 bit outputs
local RNG_MAX = 2^32 - 1 
local BIT32_MAX = 2^32

-- avoids modulo bias when constraining a value to between min & max
local lemire_constrain = function(bit_generator : () -> number,min : number,max : number)
    local range = max - min + 1

    local value = bit_generator()
    local multiplied,fractional = math_util.multiply32(value, range)

    if fractional < range then
        local threshold = (BIT32_MAX - range) % range

        while fractional < threshold do
            value = bit_generator()
            multiplied,fractional = math_util.multiply32(value, range)
        end
    end

    return min + multiplied 
end


interface.new = function(bit_generator : () -> number)
    local generator = {}
    generator.BitGenerator = bit_generator
    generator.type = "Generator"

    return setmetatable(generator, meta)
end

schema.random = function(self : types.Generator,... : number)
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

schema.integers = function(self : types.Generator,min : number, max : number, shape : {number})
    shape = shape or {1}

    local valid_shape,err_msg = ndarray_utils.VerifyShape(shape)

    if not valid_shape then
        exceptions.FormatException("Array", err_msg)
    end

    local size = ndarray_utils.ComputeSize(shape)
    local data = table.create(size,0)
    local strides = ndarray_utils.ComputeStrides(shape)

    for i = 1,size do
        data[i] = lemire_constrain(self.BitGenerator,min,max)
    end

    return ndArray(data, shape, strides, 0, "number")
end

schema.choice = function<T>(self : types.Generator,target : types.ndArray<T>,shape : {number})
    if target.ndim ~= 1 then
        exceptions.FormatException("Array", "Target array ndim must be 1")
    end

    shape = shape or {1}

    local valid_shape,err_msg = ndarray_utils.VerifyShape(shape)

    if not valid_shape then
        exceptions.FormatException("Array", err_msg)
    end

    local size = ndarray_utils.ComputeSize(shape)
    local data = table.create(size)
    local strides = ndarray_utils.ComputeStrides(shape)

    local max = #target

    for i = 1,size do
        local index = lemire_constrain(self.BitGenerator,1,max)
        data[i] = target[index]
    end

    return ndArray(data, shape, strides, 0, target.dtype)
end

-- distribuitions

local ziggurat_normal = function(BitGenerator : () -> number)
    local layers = 128
    local r = 3.442619855899  -- right edge
    while true do
        local layer = lemire_constrain(BitGenerator, 1, layers)

        local x_i = zig_normal.x[layer]
        local k_i = zig_normal.k[layer]

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
                x_tail = -math.log(math.max(BitGenerator() / (RNG_MAX),0)) / r
                y_tail = -math.log(math.max(BitGenerator() / (RNG_MAX),0))
            until y_tail + y_tail > x_tail * x_tail

            local value = BitGenerator() / (RNG_MAX) > 0.5 and r + x_tail or -(r + x_tail)
            return value
        end
        
        -- rejection test
        -- sees if y falls under the curve exp(-0.5x²)
        local y_value = zig_normal.f[layer] + (zig_normal.f[layer + 1] - zig_normal.f[layer]) * BitGenerator() / (RNG_MAX)

        if y_value >= math.exp(-0.5 * x_value ^ 2) then continue end
        local value = BitGenerator() / (RNG_MAX) > 0.5 and x_value or -x_value
        return value
    end
end

local ziggurat_exp = function(BitGenerator : () -> number)
    local layers = 128
    local r = 7.69711747013104972  -- right edge
    while true do
        local layer = lemire_constrain(BitGenerator, 1, layers)

        local x_i = zig_exp.x[layer]
        local k_i = zig_exp.k[layer]

        local u = BitGenerator() / (RNG_MAX)

        local x_value = u * x_i

        -- fast path
        if u < k_i then
            return x_value
        end

        -- slow path
        if BitGenerator() / (RNG_MAX) * zig_exp.f[layer] < math.exp(-x_value) then
            return x_value
        end

        -- tail handling
        if layer == 1 then
            return zig_exp.x[1] - math.log(math.max(BitGenerator() / (RNG_MAX),0))
        end

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
        data[i] = mean + std_dev * ziggurat_normal(self.BitGenerator)
    end

    return ndArray(data, shape, strides, 0, "number")
end

schema.lognormal = function(self : types.Generator,mean : number,std_dev : number,shape : {number})
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
        data[i] = math.exp(mean + std_dev * ziggurat_normal(self.BitGenerator))
    end

    return ndArray(data, shape, strides, 0, "number")
end

-- scale (or mean) β where rate λ = 1/β
schema.exponential = function(self : types.Generator,scale : number,shape : {number})
    scale = scale or 1
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
        data[i] = scale * ziggurat_exp(self.BitGenerator)
    end

    return ndArray(data, shape, strides, 0, "number")
end

schema.uniform = function(self : types.Generator,min : number, max : number, shape : {number})
    shape = shape or {1}

    local valid_shape,err_msg = ndarray_utils.VerifyShape(shape)

    if not valid_shape then
        exceptions.FormatException("Array", err_msg)
    end

    local size = ndarray_utils.ComputeSize(shape)
    local data = table.create(size,0)
    local strides = ndarray_utils.ComputeStrides(shape)

    for i = 1,size do
        local value = self.BitGenerator() / RNG_MAX
        data[i] = value * (max - min) + min
    end

    return ndArray(data, shape, strides, 0, "number")
end

-- discrete distributions
-- λ representing rate
schema.poisson = function(self : types.Generator,lambda : number,shape : {number})
    lambda = lambda or 1
    shape = shape or {1}

    local valid_shape,err_msg = ndarray_utils.VerifyShape(shape)

    if not valid_shape then
        exceptions.FormatException("Array", err_msg)
    end

    local size = ndarray_utils.ComputeSize(shape)
    local data = table.create(size,0)
    local strides = ndarray_utils.ComputeStrides(shape)

    local L = math.exp(-lambda)

    local slam = math.sqrt(lambda)
    local b = 0.931 + 2.53 * slam
    local a = -0.059 + 0.02483 * b

    local invalpha = 1.1239 + 1.1328 / (b - 3.4)
    local vr = 0.9277 - 3.6224 / (b - 2)

    for i = 1,size do

        if lambda < 10 then
            -- knuths method
            local k = 0
            local p = 1
            while p > L do
                k += 1
                local uniform = self.BitGenerator()
                p *= uniform
            end

            data[i] = k - 1
        else
            -- PTRS method
            local x
            while true do
                local u = ((self.BitGenerator() + 0.5) / (RNG_MAX)) - 0.5
                local v = (self.BitGenerator() / (RNG_MAX))

                local us = 0.5 - math.abs(u)


                if us == 0 then continue end
                if u > 1 - 1.12 * us * us then continue end
                
                x = math.floor((2*a/us + b) * u + lambda + 0.43)
                
                if v <= vr then break end
                
                local logarithmic_prob = -lambda + x * math.log(lambda) - math_util.log_gamma(x)

                if logarithmic_prob >= math.log(v) then break end
            end 

            data[i] = x            
        end

    end
    return ndArray(data, shape, strides, 0, "number")
end

-- shuffles

schema.shuffle = function<T>(self : types.Generator,target : types.ndArray<T>,axis : number)
    if target.ndim == 0 then return end

    axis = axis or target.ndim - 1

    for i = target.Shape[1], 2,-1 do
        local index = lemire_constrain(self.BitGenerator, 1, i - 1)

        target:swap(index,i,axis)
    end

end

schema.permutation = function<T>(self : types.Generator,target : types.ndArray<T> | number,axis : number)
    local new_array : types.ndArray<T>

    if type(target) == "number" then
        local data = {}
        for i = 1,target do table.insert(data,i) end

        new_array = ndArray(data, {target}, {1}, 0, "number")
    else
        if target.ndim == 0 then return end

        new_array = target:copy()
    end


    axis = axis or new_array.ndim - 1

    for i = new_array.Shape[1], 2,-1 do
        local index = lemire_constrain(self.BitGenerator, 1, i - 1)

        new_array:swap(index,i,axis)
    end

    return new_array
end

return interface