---
icon: lucide/rocket
title: integration example
description: example of applying integration
---

let f(x,y) = exp(-(x² + y²)) ∙ sin(x) for -2 ≤ x ≤ 2 and -2 ≤ y ≤ 2

find:
1. Find the volume |f(x,y)| in the specified x and y range
2. Find the volume |f(x,y)| only in the region where √(x² + y^²) > 0.5

```lua

local numluau = require("../numluau/numluau")

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