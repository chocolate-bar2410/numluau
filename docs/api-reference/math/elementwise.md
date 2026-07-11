---
title: luau math wrappers
---

```luau
function numluau.<[mathfunc]>(
    Array : types.ndArray<number>
) : types.ndArray<number>
```

The numluau provides wrapper functions that allow you to apply Luau `math` function to an `ndArray<number>` and return the result as a `ndArray<number>`.

# Supported functions

The following wrappers are available:

`abs`, `acos`, `asin`, `atan`, `ceil`, `cos`, `cosh`, `deg`, `exp`, `floor`,
`log`, `log10`, `modf`, `rad`, `round`, `sign`, `sin`, `sinh`, `sqrt`, `tan`,
and `tanh`.

`log2` is also available and applies `math.log(value, 2)` to each item.

# Parameters

### Array : types.ndArray<number\>
The numeric array the function is applied to.

# Returns -> `ndArray<number>`

A new `ndArray<number>` containing the element-wise result. The input array is
copied before values are transformed.

# Example

```luau
local numluau = require("path.to.numluau")

local input = numluau.array({-2.7, -0.5, 0, 1.2, 3.9})

local absolute = numluau.abs(input)
local rounded = numluau.round(input)

print(absolute) -- array([2.7 0.5 0 1.2 3.9])
print(rounded) -- array([-3 -1 0 1 4])
```