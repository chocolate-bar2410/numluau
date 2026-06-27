---
title: max
---

```luau
function numluau.max<T>(
    Array : types.ndArray<T>,
    Axis : number?
) : types.ndArray<T>,
```
Produces the max value of all the values across an Axis.
If an axis is not provide, it will instead max all the items in the ndArray and return a 0-Dimensional array.
# Parameters

### Array : types.ndArray<T\>
the array the function is being applied to

### Axis : number?
the axis where this is applied across.

# Returns -> `ndArray<number>`
A new ndArray of the max value of the items across an axis.