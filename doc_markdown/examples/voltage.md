---
icon: lucide/rocket
title: circuit linear equation example
description: example of solving a linear equation for a circuit
---
After examining a circuit full of resistors, you find that the voltage at 4 specified points is given by:

3v₁ + 2v₂ + 3v₃ + 10v₄ = 4
2v₁ - 2v₂ + 5v₃ + 8v₄  = 1
3v₁ + 3v₂ + 4v₃ + 9v₄  = 3
3v₁ + 4v₂ - 3v₃ - 7v₄  = 2

where v₁ - v₄ are voltages
find v₁,v₂,v₃,v₄

```lua
local numluau = require("../numluau/numluau")
local A : numluau.ndArray<number> = numluau.array({
    {3, 2, 3, 10},
    {2,-2, 5,  8},
    {3, 3, 4,  9},
    {3, 4,-3, -7},
})

local C : numluau.ndArray<number> = numluau.array({4,1,3,2})
local voltages = numluau.linalg.solve(A, C)

print(string.format("voltage results: \nv₁ : %g \nv₂ : %g \nv₃ : %g  \nv₄ : %g",voltages[1],voltages[2],voltages[3],voltages[4]))
```

``` title="output"
> voltage results:
v₁ : 0.783784
v₂ : 0.036036
v₃ : -0.675676 
v₄ : 0.36036
```