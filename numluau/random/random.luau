local Exceptions = require("@numluau/Exceptions")
local types = require("../types")
local ndArray = require("../ndarray/ndarray")

local exceptions = require("../Exceptions")
local ndarray_utils = require("../ndarray/ndarray_utils")

local zig_lookup = require("./zigguratt")

local module = {}

export type interface = {
    seed : (seed : number) -> (),
    rand : (...number) -> types.ndArray<number>,
    normal : (mean : number,std_dev : number,shape : {number}) -> types.ndArray<number>,
}

module.seed = function(seed : number)
    math.randomseed(seed)
end

module.rand = function(... : number)
    local shape = {...} or {1}
    
    local valid_shape,err_msg = ndarray_utils.VerifyShape(shape)

    if not valid_shape then
        Exceptions.FormatException("Array", err_msg)
    end

    local size = ndarray_utils.ComputeSize(shape)

    local data = {}
    local strides = ndarray_utils.ComputeStrides(shape)

    for i = 1,size do
        table.insert(data,math.random())
    end

    return ndArray(data, shape, strides, 0, "number")
end

module.normal = function(mean : number,std_dev : number,shape : {number})
    shape = shape or {1}

    local valid_shape,err_msg = ndarray_utils.VerifyShape(shape)

    if not valid_shape then
        Exceptions.FormatException("Array", err_msg)
    end

    local size = ndarray_utils.ComputeSize(shape)

    local data = {}
    local strides = ndarray_utils.ComputeStrides(shape)
    
    -- using zigguratt algorithm

    local layers = 128
    local r = 3.442619855899  -- right edge

    for i = 1, size do
        while true do
            local layer = math.random(1,layers)

            local x_i = zig_lookup.x[layer]
            local k_i = zig_lookup.k[layer]

            local u = math.random()

            local x_value = u * x_i

            if u < k_i then
                local value = math.random() > 0.5 and x_value or -x_value
                table.insert(data,value)
                break
            end

            -- slow path

            -- top layer uses tail sampling
            if layer == 1 then
                local x_tail
                local y_tail

                repeat
                    x_tail = -math.log(math.random()) / r
                    y_tail = -math.log(math.random())
                until y_tail + y_tail > x_tail * x_tail

                local value = math.random() > 0.5 and r + x_tail or -(r + x_tail)
                table.insert(data,value)
                break
            end
            
            -- rejection test
            -- sees if y falls under the curve exp(-0.5x²)
            local y_value = zig_lookup.f[layer] + (zig_lookup.f[layer + 1] - zig_lookup.f[layer]) * math.random()

            if y_value >= math.exp(-0.5 * x_value ^ 2) then continue end
            local value = math.random() > 0.5 and x_value or -x_value
            table.insert(data,value)
        end
    end

    for i = 1,size do
        data[i] = mean + std_dev * data[i]
    end


    return ndArray(data, shape, strides, 0, "number")
end



return module :: interface