---
title: meshgrid
---

```luau
function numluau.meshgrid<T>(
    X : types.ndArray<T>,
    Y : types.ndArray<T>
): numluau.ndArray<T>, numluau.ndArray<T>
```
Given two 1-Dimensional ndArrays, will produce two 2-Dimension ndArrays.
The ndArrays will have the dimensions of n x m

where n is the length of `X`, and m is the length of `Y`

# Parameters

### X : types.ndArray<T/>
The values applied across the rows of the first ndArray.

### Y : types.ndArray<T/>
The values applied across the columns of the second ndArray.

# Returns -> `(ndArray<T>,ndArray<T>)`
the first ndArray will be a grid where `X` items are filled across the rows.
the second ndArray will be a grid where `Y` items are filled across the columns.