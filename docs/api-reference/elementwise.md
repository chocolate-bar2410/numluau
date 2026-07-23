---
icon: octicons/note-16
---

<h1 class = "tsukuyomi-api-header" markdown> 
<span class="tsukuyomi-api-icon" markdown>:octicons-note-24:</span> 
<span class="tsukuyomi-api-name">element-wise math</span> 
</h1> 


```luau
function numluau.abs(
    Array : types.ndArray<number>
) : types.ndArray<number>
```

The element-wise math functions apply one Luau `math` function to every value in
an `ndArray<number>` and return the result as a new `ndArray<number>`.

## Supported functions

The following wrappers are available:

`abs`, `acos`, `asin`, `atan`, `ceil`, `cos`, `cosh`, `deg`, `exp`, `floor`,
`log`, `log10`, `modf`, `rad`, `round`, `sign`, `sin`, `sinh`, `sqrt`, `tan`,
and `tanh`.

`log2` is also available and applies `math.log(value, 2)` to each item.

## Parameters
<h3> 
Array<span class = "tsukuyomi-api-type"> : ndArray &lt;number&gt; </span> 
</h3>
The numeric array the function is applied to.

<h2>
Returns -><span class = "tsukuyomi-api-type"> ndArray &lt;number&gt; </span> 
</h2>

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