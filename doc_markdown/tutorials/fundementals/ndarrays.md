---
icon: lucide/rocket
title: N-Dimensional arrays
description: Basics of N-Dimensional arrays
---
In numluau, most of your math is going to be done using N-Dimensional Arrays.

## creating N-Dimensional arrays
the easiest way is to create a `array` it using a table.

```luau hl_lines="1"
local a = numluau.array({1,2,3,4,5})
```

Arrays simplify operations that would be otherwise tedious using regular tables.
Removing the need for long for loops and table allocations.

```luau title="using regular tables" hl_lines="5-7"
local a = {1,2,3,4,5}
local b = {10,20,30,40,50}

local c = {}
for i = 1,5 do
    c[i] = a[i] + b[i]
end

print(c) -- array([11 22 33 44 55])
```

```luau title="using arrays" hl_lines="5"
local a = numluau.array({1,2,3,4,5})
local b = numluau.array({10,20,30,40,50})

local c = a + b
print(c) -- array([11 22 33 44 55])
```

Arrays can also take in nested tables, to represent higher dimensional arrays

```luau
local a = numluau.array({
    {1,2,3},
    {4,5,6}
})
```

## restrictions to arrays
there are restrictions when making a array

1. all items must have the same data type  
1. the shape of the array must be retangular not jagged  
1. once created, you cannot change the size of an array  

=== "Incorrect"
    ```luau
    -- these dont have the same types
    local a = numluau.array({1,"hello",false})

    -- row 1 has more items than row 2
    local b = numluau.array({
        {1,2,3},
        {1,2}
    })

    -- c is being indexed out of bounds
    local c = numluau.array({1,2,3,4,5})
    c[6] = 6
    ```
=== "Correct"
    ```luau
    -- these do have the same types
    local a = numluau.array({1,2,3})

    -- all the rows have the same size
    local b = numluau.array({
        {1,2,3},
        {1,2,3}
    })

    -- c is being indexed in bounds
    local c = numluau.array({1,2,3,4,5})
    c[5] = 6
    ```

### 0d arrays
While you can make arrays 2d, 3d, 4d etc. you can also create 0d arrays.
These arrays represent a single value.

```luau
local a = numluau.array(15)
a += 2
print(a) -- array(17)
```

To retrieve the value from this array you can use `:Item()`.
```lua hl_lines="2"
local a = numluau.array(255)
print(a:item())
```

## properties of Arrays

- dtype - The data type of the items of the array.
- ndim - The dimension of the array.
- shape - A table that determins the dimensions of the array.
- strides - A table that describes how to index the array.
- buffer - The raw table that holds the data.
- offset - Determines the first item of the array.