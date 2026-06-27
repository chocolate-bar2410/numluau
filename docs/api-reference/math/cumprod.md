---
title: cumprod
---

```luau
function numluau.cumprod<T>(
    Array : types.ndArray<T>,
    Axis : number?
) : types.ndArray<T>,
```
Produces a ndArray containing the cummulative products.
Either applied to every item sequentially or across an axis.
# Parameters

### Array : types.ndArray<T\>
The array the function is being applied to.

### Axis : number?
The axis where this is applied across.

# Returns -> `ndArray<number>`
A ndArray containing the cummulative products of `Array`.