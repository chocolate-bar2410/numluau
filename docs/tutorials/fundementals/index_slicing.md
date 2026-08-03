---
title: Indexing and slicing
description: Indexing and slicing arrays
---
numluau allows you to index arrays in many ways.

## indexing

Arrays are intended to work similarly to how you'd use tables as arrays in luau.
The indexes of a Array start at 1 and go up.

So the first element is at index 1, the second is at index 2 etc.

This is standard for Arrays in languages like julia or R but differs from python's numpy arrays which start at 0.

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

We can use a negative index to index from the back of the array instead of the front
```luau
local a = numluau.array({1,2,3,4,5})

print(a[-1]) -- 5
print(a[-2]) -- 4
```

Arrays can also be indexed using strings, allowing you to index is other ways.

If we wanted to index a 2d array, we could use regular table syntax.
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
Now lets say we're working with data but only want a subset of that data.
Either because the data is large, or you're data contains multiple channels like left/right channels for audio or red/blue/green/alpha for images.

We can use a special index to get a subsection of our data from our array.
This is what we call a `slice`.

### 1d arrays

Using the index `first:last:step`, we can retrieve a portion of the array with only some items.
```luau
local a = numluau.array({1,2,3,4,5})

-- get items 1-3
print(a["1:3"]) -- array([1 2 3])

-- get every second item
print(a["1:5:2"]) -- array([1 3 5])
```

A slice doesn't generate a copy of the array, but instead it points to the same data but steps through it differently.  
This is what we call a `view`.

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

We can also apply this notion to higher dimensional arrays

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

We can expand this to multiple dimensions by combining `first:last:step` and `col, row`.
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
