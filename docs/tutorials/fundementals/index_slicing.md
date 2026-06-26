---
icon: lucide/rocket
title: Indexing and slicing
description: the basics of ndArrays
---
numluau allows you to index the ndArray in many ways.

## indexing

indexing works similarly to how you'd index tables.
ndArrays are 1-indexed, meaning arrays start from 1.

=== "1d array"
    ```luau
    local a = numluau.array({1,2,3,4,5})

    print(a[2]) -- 2
    ```
=== "2d array"
    ```luau
    local a = numluau.array({
        {1,2,3,4},
        {2,4,6,8}
    })

    print(a[2][3]) -- 6
    ```

we can use a negative index to index from the back of the ndArray instead of the front
```luau
local a = numluau.array({1,2,3,4,5})

print(a[-1]) -- 5
print(a[-2]) -- 4
```

ndArrays can also be indexed using strings, allowing you to index is other ways.

if we wanted to index a 2d array, we could use regular table syntax.
Or we can use the index `col, row` to also get that item.

```luau hl_lines="6 7"
local a = numluau.array({
    {1,2,3,4},
    {2,4,6,8}
})

print(a[2][3])    -- 6
print(a["2, 3"])  -- 6
```

## slicing
Sometimes you dont want to get a single item, but instead a collection of items.
This is what we call a **slice**.

### 1d arrays

Using the index `first:last:step`, we can retrieve a portion of the array with only some items.
```luau
local a = numluau.array({1,2,3,4,5})

-- get items 1-3
print(a["1:3"]) -- array([1 2 3])

-- get every second item
print(a["1:5:2"]) -- array([1 3 5])
```

When we create a slice, it doesn't create a whole new copy.
This means if we mutate the slice, it will affect the original.

```luau
local a = numluau.array({1,2,3,4,5})
local b = a["1:3"]

b[1] = 125

print(a) -- array([125 2 3 4 5])
```

You can also leave a parameter empty and it will assume the value for you.

```luau
local a = numluau.array({1,2,3,4,5})

print(a["1::2"])
print(a["::2"])
print(a[":3"])
```
``` title="output"
> array([1 3 5])
> array([1 3 5])
> array([1 2 3])
```

### 2d+ arrays

we can also apply this notion to higher dimensional arrays

```luau
local a = numluau.array({
    {1,2,3,4},
    {5,6,7,8}
})
-- gets the entire 2nd row
print(a["2"])

-- gets every item on the 2nd column
print(a[":,2"])
```

```title="output"
> array([5 6 7 8])
> array([2 6])
```

we can expand this to multiple dimensions by combining `first:last:step` and `col, row`
```luau
local a = numluau.array({
    {1,2,3,4},
    {5,6,7,8},
    {9,10,11,12},
    {13,14,15,16},
})

print(a["1:2, 1:2"])
print(a["1:2, 1:3:2"])

print(a["::2"])
print(a[":,::2"])
```
```title="output"
> array([ 
    [1 2] 
    [5 6] 
])
> array([ 
    [1 3] 
    [5 7] 
])
> array([
  [1 2 3 4]
  [9 10 11 12]
])
> array([
  [1 3]
  [5 7]
  [9 11]
  [13 15]
])
```
