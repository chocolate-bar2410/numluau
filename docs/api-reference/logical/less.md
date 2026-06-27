---
title: less
---

```luau
function numluau.less<T>(
    x1 : numluau.ndArray<T> | T,
    x2 : numluau.ndArray<T> | T
): numluau.ndArray<boolean>
```
given 2 values, will produce a boolean mask from the condition x1 < x2
# Parameters

## x1 : numluau.ndArray<T\> | T
the first value.

## x2 : numluau.ndArray<T\> | T
the second value.

# Returns -> `ndArray<boolean>`
a new boolean mask ndArray.