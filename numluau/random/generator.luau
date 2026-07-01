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

    local vr = 0.9277 - 3.6224 / (b - 2)

    if lambda < 10 then
            -- knuths method
        for i = 1,size do
            local k = 0
            local p = 1
            while p > L do
                k += 1
                local uniform = self.BitGenerator()
                p *= uniform
            end

            data[i] = k - 1
        end
    else
        -- PTRS method
        for i = 1,size do
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


-- simpler implementation since numpy's BTPE is like 500 lines of gotos
local function BTPE(bit_generator : () -> number,trial_num : number,probability) : number
    if probability > 0.5 then return trial_num - BTPE(bit_generator,trial_num,1 - probability) end
    
    local mean = trial_num * probability

    -- numpy constants
    local r = math.min(probability,(1 - probability))
    local q = 1 - r

    local fm = trial_num * r + r
    local m = math.floor(fm)
    local xm = m + 0.5

    local s = r / q
    local a0 = s * (trial_num + 1)
    local nrq = trial_num * r * q

    local c = 0.134 + 20.5 / (15.3 + mean);

    local p1 = math.floor(2.195 * math.sqrt(trial_num * probability * (1 - probability)) - 4.6 * (1 - probability)) + 0.5
    local p2 = p1 * (1 + 2 * c)

    local xl = xm - p1
    local xr = xm + p1

    local a = (fm - xl) / (fm - xl * r)

    local laml = a * (1 + a / 2)
    a = (xr - fm) / (xr * q)

    local lamr = a * (1 + a / 2)

    local p3 = p2 + c / laml
    local p4 = p3 + c / lamr

    while true do
        local U = (bit_generator() / (RNG_MAX))* p4
        local V = bit_generator() / (RNG_MAX)

        local k

        if U <= p1 then
            k = math.floor(xm - p1 * V + U)
        elseif U <= p2 then
            local x = xl + (U - p1) / c
            V = V * c + 1 - math.abs(mean - x + 0.5) / p1

            if V > 1 then
                continue
            end

            k = math.floor(x)

        elseif U <= p3 then
            k = math.floor(xl + math.log(V) / laml);

            if (k < 0) or (V == 0.0) then continue end

            V = (U - p2) * laml

        else    
            k = math.floor(xr - math.log(V) / lamr)

            if ((k > trial_num) or (V == 0.0)) then continue end

            V *= (U - p3) * lamr;
        end

        if k < 0 or k > trial_num then
            continue
        end

        local F = 1.0

        if m < k then
            for i = m + 1, k do
                F *= (a0 / i - s)
            end
        elseif m > k then
            for i = k + 1, m do
                F /= (a0 / i - s)
            end
        end

        if V <= F then
            return k
        end

        local k_abs = math.abs(k - m)

        if k_abs < nrq / 2 then
            local rho = (k_abs / nrq) * ((k_abs * (k_abs / 3 + 0.625) + 1/6) / nrq + 0.5)

            local t = -(k_abs * k_abs) / (2 * nrq)
            local A = math.log(V)

            if A > (t - rho) then return k end

            if A > (t + rho) then continue end
        else
            continue
        end

        if probability > 0.5 then
            return trial_num - k
        end

        return k
    end
end

schema.binomial = function(self : types.Generator,trial_num : number,probability : number,shape : {number})
    trial_num = math.floor(trial_num or 1)
    shape = shape or {1}

    local valid_shape,err_msg = ndarray_utils.VerifyShape(shape)

    if not valid_shape then
        exceptions.FormatException("Array", err_msg)
    end
    
    local mean = trial_num * probability
    local variance = mean * (1 - probability)
    local epsilon = 1e-6

    local size = ndarray_utils.ComputeSize(shape)
    local data = table.create(size,0)
    local strides = ndarray_utils.ComputeStrides(shape)

    if probability > 1 - epsilon then
        return trial_num - self:binomial(trial_num, 1 - probability, shape)

    elseif probability < epsilon then
        return self:poisson(mean, shape)

    elseif mean <= 30 then
        for i = 1,size do
            local result = 0
            for k = 1,trial_num do
                local uniform = self.BitGenerator() / (RNG_MAX)
                if uniform > probability then continue end

                result += 1
            end

            data[i] = result
        end
    elseif variance < 1e7 then
        for i = 1,size do
            data[i] = BTPE(self.BitGenerator,trial_num,probability)
        end
    else
        local normal = self:normal(trial_num, math.sqrt(variance), shape) -- centeral limit theorem

        for i,v in normal do
            normal.Buffer[i] = math.clamp(math.round(v),0,trial_num)
        end

        return normal
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