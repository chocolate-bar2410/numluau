# numLuau
numluau (numerical luau) is a math library for luau.

features:
- a N dimensional array object
    - broadcasting
    - sophisicated slice indexing
    - element wise operations

- linear algebra
    - linear equation solvers
    - eigen value/vectors
    - QR and LU decompositions
    - determinants
    - dot/cross products
    - matrix multiplications

and alot more

# installation

its reccomended to install using pesde
```
pesde add chocolate_bar2410/numluau
```

# quick start
require it from your packages
```lua
local numluau = require("path.to.library")
```
handling ndarrays
```lua
-- create a ndarray using a table
local array1 : numluau.ndArray<number> = numluau.array({1,2,3,4,5})
local array2 : numluau.ndArray<number> = numluau.array({5,4,3,2,1})

print(array1 + array2) -- [6 6 6 6 6]
print(array1 * array2) -- [5 8 9 8 5]
print(array1 / array2) -- [0.2 0.5 1 2 5]
print(array1 % array2) -- [1 2 0 0 0]
print(array1 * 20)     -- [20 40 60 80 100]

print(array1[1])       -- 1
print(array1["1:3"])   -- [1 2 3]

-- numluau allows you to convert nested tables
local array3 : numluau.ndArray<number> = numluau.array({{2,4},{6,8},{10,12}})
print(array3[1][1])          -- 2
print(array3[":,2"])         -- [4 8 12]

print(array3:reshape(2,3))   -- [[2  4  6] [8 10 12]]
print(numluau.sum(array3))   -- [42]
print(numluau.sum(array3,1)) -- [(2 + 6 + 10) (4 + 8 + 12)] -> [18 24]
```

# example code
circuit voltage problem
```lua
--[[
After examining a circuit full of resistors, you find that the voltage at 4 specified points is given by
(3 * v1) + (2 * v2) + (3 * v3) + (10 * v4) = 4
(2 * v1) - (2 * v2) + (5 * v3) + (8  * v4) = 1
(3 * v1) + (3 * v2) + (4 * v3) + (9  * v4) = 3
(3 * v1) + (4 * v2) - (3 * v3) - (7  * v4) = 2

where v1 - v4 are voltages
find v1,v2,v3,v4
]]
local numluau = require("../numluau/numluau")
local A : numluau.ndArray<number> = numluau.array({
    {3, 2, 3, 10},
    {2,-2, 5,  8},
    {3, 3, 4,  9},
    {3, 4,-3, -7},
})

local C : numluau.ndArray<number> = numluau.array({4,1,3,2})
local voltages = numluau.linalg.solve(A, C)

print(string.format("voltage results: \nv1 : %g \nv2 : %g \nv3 : %g  \nv4 : %g",voltages[1],voltages[2],voltages[3],voltages[4]))
--[[
voltage results:
v1 : 0.783784
v2 : 0.036036
v3 : -0.675676 
v4 : 0.36036
]]
```

integration problem
```lua
--[[
let f(x,y) = exp(-(x² + y²)) ∙ sin(x) for -2 ≤ x ≤ 2 and -2 ≤ y ≤ 2

find:
1. Find the volume |f(x,y)| in the specified x and y range
2. Find the volume |f(x,y)| only in the region where √(x² + y^²) > 0.5
]]
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
--[[
volume of f(x,y):
1.4861858145125453

volume of f(x,y) inside √(x² + y^²) > 0.5:
1.344765293020408
]]
```