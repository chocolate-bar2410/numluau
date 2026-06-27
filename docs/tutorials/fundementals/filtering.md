---
icon: lucide/rocket
title: Filtering
description: filtering N-Dimensional arrays
---

## boolean arrays
Arrays dont have to always contain numbers.

For instance, here is a array that holds boolean values.
```luau
local a = numluau.array({true,false,false})
```

If we index a array with another array that contains booleans, we can retrieve all the items where a true value is.
This is what we call `masking`.

```luau
local mask = numluau.array({true,false,false,true,false})
local a = numluau.array({1,2,3,4,5})

print(a[mask]) -- array([1 4])
```

Doing this on multidimensional arrays flatten the result into a 1d array.

```luau
local mask = numluau.array({
    {true,false,false,true,false},
    {false,false,true,true,false}
})
local a = numluau.array({
    {1,2,3,4,5},
    {6,7,8,9,10}
})

print(a[mask]) -- array([1 4 8 9])
```

If you want to preserve the shape we can use the `numluau.where()` function.
This will create a new array with our same shape but replaces values where false values are, are replaced with a `fill` value.

```luau
local mask = numluau.array({
    {true,false,false,true,false},
    {false,false,true,true,false}
})
local a = numluau.array({
    {1,2,3,4,5},
    {6,7,8,9,10}
})

local fill_value = 0
local result = numluau.where(mask,a,fill_value)
print(result)
```
``` title="output"
> array([
  [1 0 0 4 0]
  [0 0 8 9 0]
])
```

## comparison
While we could use `boolean masks` for masking. Sometimes we want to be able to create these masks from conditions.
This is where comparisons functions come in.

| function             | equivalent |
|:---------------------|:----------:|
|numluau.equal         |   a = b    |
|numluau.greater       |   a > b    |    
|numluau.greater_equal |   a ≥ b    |        
|numluau.less          |   a < b    |
|numluau.less_equal    |   a ≤ b    |     

```luau
local a = numluau.array({1,2,3,4,5})
local b = numluau.array({5,4,3,2,1})

local mask = numluau.greater_equal(a,b)

print(a[mask]) -- array([3 4 5])
```

to work with multiple conditions we can use our logical functions.
`numluau.logical_and()` and `numluau.logical_or()` act like luau's `and` and `or` operators.

| function             | equivalent                |
|:---------------------|:-------------------------:|
|numluau.logical_and   |          a and b          |
|numluau.logical_or    |          a or b           |    
|numluau.logical_not   |          not a            |        
|numluau.logical_xor   |          a ≠ b            |


```luau
local a = numluau.array({1,2,3,4,5})
local b = numluau.array({5,4,3,2,1})

local mask1 = numluau.greater_equal(a,b)
local mask2 = numluau.equal(a % 2, 0)

print(a[numluau.logical_and(mask1,mask2)]) -- array([4])
```