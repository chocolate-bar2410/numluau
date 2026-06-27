---
title: cumsum
---

```luau
function numluau.cumsum<T>(
    Array : types.ndArray<T>,
    Axis : number?
) : types.ndArray<T>,
```
Produces a ndArray containing the cummulative sums.
Either applied to every item sequentially or across an axis.
# Parameters

### Array : types.ndArray<T\>
The array the function is being applied to.

### Axis : number?
The axis where this is applied across.

# Returns -> `ndArray<number>`
A ndArray containing the cummulative sums of `Array`.