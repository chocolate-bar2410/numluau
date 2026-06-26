---
icon: lucide/rocket
title: Arithmetic
description: doing arithmetic on ndArrays
---
## basic operations
Shown [previously](./ndarrays) ndArrays can do operations between eachother.
allowing for basic operations like addition, subtraction, multiplication etc.
```luau
local a = numluau.array({1,2,3,4})
local b = numluau.array({2,4,6,8})

print(a + b) -- array([3 6 9 12])
print(a - b) -- array([-1 -2 -3 -4])
print(a * b) -- array([2 8 18 32])
```

### math functions
numluau also provides access to math functions like square root or ceil.
```luau
local a = numluau.array({1,2.5,3.99})

print(numluau.sqrt(a)) -- array([1 1.5811388 1.9974984])
print(numluau.ceil(a)) -- array([1 3 4])
print(numluau.exp(a))  -- array([2.7182818 12.182494 54.054889])
```

### scalar arithmetic
doing arithmetic between a scalar and a ndArray will apply that scalar to every item of that ndArray
```luau
local a = numluau.array({1,2,3,4})

print(a + 5) -- array([6 7 8 9])
print(a * 2) -- array([2 4 6 8])
print(a ^ 3) -- array([3 9 27 81])
```

heres an example of how you can use these
```luau title="calculating the volumes of cylinders"
local radii   = numluau.array({1,5,2.5,10})
local heights = numluau.array({2,10,22,100})

local volumes = (radii ^ 2) * math.pi * heights
volumes = numluau.round(volumes)

print(volumes) -- array([6 785 432 31416])
```

## broadcasting
Numluau allows you to perform operations between ndArrays by virtually expanding dimensions, so that they match in shape.
This process is called **broadcasting**.

broadcasting can only be applied either if:
1. The dimensions are the same size.
2. Atleast one dimension is equal to one.

```luau
local a = numluau.array({
    {1,2,3},
})
local b = numluau.array({
    {0, 0, 0},
    {10,10,10},
    {20,20,20},
    {30,30,30},
})

print(a + b)
```
``` title="output"
> array([
  [1 2 3]
  [11 12 13]
  [21 22 23]
  [31 32 33]
])
```

!!! danger
    doing a operation between ndArrays that dont follow these rules will produce a broadcasting error.

```luau
local a = numluau.array({
    {1,2,3},
    {4,5,6},
})
local b = numluau.array({
    {0, 0, 0},
    {10,10,10},
    {20,20,20},
    {30,30,30},
})

print(a + b)
```
``` title="output error" 
Error with broadcasting: Tried to broadcast incompatible arrays
```

If the two ndArrays have different dimensions, the missing dimensions are filled in with ones.

```luau
local a = numluau.array({2,5})
local b = numluau.array({
    {0,0},
    {1,1},
    {2,2},
    {3,3},
    {4,4},
})

-- a.Shape : [2]
-- b.Shape : [2, 5]

-- a.Shape has no 2nd dimension so it acts as if its 2nd dimension was 1
print(a * b)
```
``` title="output"
> array([
  [0 0]
  [2 5]
  [4 10]
  [6 15]
  [8 20]
])
```

In some cases, both ndArrays will be expanded during broadcasting.
```luau
local a = numluau.array({1,2,3,4,5})
local b = numluau.array({
    {1},
    {2},
    {3},
    {4},
    {4},
})

print(a * b)
```
``` title="output"
> array([
  [1 2 3 4 5]
  [2 4 6 8 10]
  [3 6 9 12 15]
  [4 8 12 16 20]
  [4 8 12 16 20]
])
```

