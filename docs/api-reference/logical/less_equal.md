---
title: less_equal
---

```luau
function numluau.less_equal<T>(
    x1 : types.ndArray<T> | T,
    x2 : types.ndArray<T> | T
): numluau.ndArray<boolean>
```
given 2 values, will produce a boolean mask from the condition x1 ≤ x2
# Parameters

## x1 : types.ndArray<T/> | T
the first value.

## x2 : types.ndArray<T/> | T
the second value.

# Returns -> `ndArray<boolean>`
a new boolean mask ndArray.