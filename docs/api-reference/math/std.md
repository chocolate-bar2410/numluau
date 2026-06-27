---
title: std
---

```luau
function numluau.std<T>(
    Array : types.ndArray<T>,
    Axis : number?
) : types.ndArray<T>,
```
Produces the standard deviation of values across an Axis.
If an axis is not provide, it will instead get the standard deviation of all the items in the ndArray and return a 0-Dimensional array.
# Parameters

### Array : types.ndArray<T\>
the array the function is being applied to

### Axis : number?
the axis where this is applied across.

# Returns -> `ndArray<number>`
A new ndArray of the standard deviation of the items across an axis.