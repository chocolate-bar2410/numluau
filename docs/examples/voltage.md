---
icon: octicons/zap-24
title: circuit linear equation
description: example of solving a linear equation for a circuit
---

After examining a circuit full of resistors, you find that the voltage at 4 specified points is given by:

$$\displaylines{
3v_{1} + 2v_{2} + 3v_{3} + 10v_{4} = 4 \\
2v_{1} - 2v_{2} + 5v_{3} + 8v_{4}  = 1 \\
3v_{1} + 3v_{2} + 4v_{3} + 9v_{4}  = 3 \\
3v_{1} + 4v_{2} - 3v_{3} - 7v_{4}  = 2 \\
}$$

Where $v_{1} - v_{4}$ are voltages. <br>
Find $v_{1},v_{2},v_{3},v_{4}$. <br>

```lua
local numluau = require("@numluau")
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