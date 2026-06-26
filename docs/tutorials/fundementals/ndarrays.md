---
icon: lucide/rocket
title: N-Dimensional arrays
description: the basics of ndArrays
---
In numluau, most of your math is going to be done using N-Dimensional Arrays (ndArrays).

### creating N-Dimensional arrays
to create a ndArray, the easiest way is to instanciate it using a table.

```luau hl_lines="1"
local a = numluau.array({1,2,3,4,5})
```

ndArrays simplify operations that would be otherwise tedious using regular tables.
removing the need for long for loops and table allocations

using regular tables
```luau hl_lines="5-7"
local a = {1,2,3,4,5}
local b = {10,20,30,40,50}

local c = {}
for i = 1,5 do
    c[i] = a[i] + b[i]
end

print(c) -- 11 22 33 44 55
```

using ndArrays
```luau hl_lines="5"
local a = numluau.array({1,2,3,4,5})
local b = numluau.array({10,20,30,40,50})

local c = a + b
print(c) -- 11 22 33 44 55
```

ndArrays can also take in nested tables, to represent higher dimensional arrays

```luau
local a = numluau.array({
    {1,2,3},
    {4,5,6}
})
```

### restrictions to ndArray
there are restrictions when making a ndArray

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