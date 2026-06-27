---
title: sum
---

```luau
function numluau.sum<T>(
    Array : types.ndArray<T>,
    Axis : number?
) : types.ndArray<T>,
```
Produces the sum of values across an Axis.
If an axis is not provide, it will instead sum all the items in the ndArray and return a 0-Dimensional array.
# Parameters

### Array : types.ndArray<T\>
The array the function is being applied to.

### Axis : number?
The axis where this is applied across.

# Returns -> `ndArray<number>`
A new ndArray of the sum of the items across an axis.