---
icon: octicons/graph-bar-horizontal-24
title: integration example
description: example of applying integration
---
let the function be defined as:

$$
f(x,y) = e^{-(x^2 + y^2)} \cdot \sin(x)
$$

over the domain $D = {(x,y) \in \mathbb{R} ^ 2 \mid -2 \le x \le 2, -2 \le y \le 2}$

find: <br>
1. The volume under $|f(x,y)|$ over the entire domain.
$$
\iint_{D}|f(x,y)|\,dx\,dy
$$
2. The volume under $|f(x,y)|$ restricted to the region where $\sqrt{x^2 + y^2} > 0.5$.

$$\displaylines{
\iint_{R}|f(x,y)|\,dx\,dy \\
R = {(x,y) \in D \mid \sqrt{x^2 + y^2} > 0.5} \\
}$$

```lua

local numluau = require("@numluau")

local grid_x,grid_y = 1000,1000

local x = numluau.linspace(-2, 2, grid_x)
local y = numluau.linspace(-2, 2, grid_y)

local xv,yv = numluau.meshgrid(x,y)

local Z = numluau.exp(-(xv^2 + yv^2)) * numluau.sin(xv)

local dx = numluau.diff(x)[1]
local dy = numluau.diff(y)[1]

local volume = numluau.sum(numluau.abs(Z:flatten())) * dx * dy

local f = Z[numluau.greater(xv^2 + yv^2,0.5 ^ 2)]
local volume_contained = numluau.sum(numluau.abs(f:flatten())) * dx * dy
print("volume of |f(x,y)|:\n" .. volume:item() .. "\n")
print("volume of |f(x,y)| inside √(x² + y^²) > 0.5:\n" .. volume_contained:item())
```

``` title="output"
> volume of f(x,y):
1.4861858145125453

> volume of f(x,y) inside √(x² + y^²) > 0.5:
1.344765293020408
```