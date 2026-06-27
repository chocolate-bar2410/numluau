---
title: var
---

```luau
function numluau.var<T>(
    Array : types.ndArray<T>,
    Axis : number?
) : types.ndArray<T>,
```
Produces the variance of values across an Axis.
If an axis is not provide, it will instead get the variance of all the items in the ndArray and return a 0-Dimensional array.
# Parameters

### Array : types.ndArray<T\>
the array the function is being applied to

### Axis : number?
the axis where this is applied across.

# Returns -> `ndArray<number>`
A new ndArray containing variances of the items across an axis.