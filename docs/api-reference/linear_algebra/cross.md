---
title: cross
---

```luau
function numluau.linalg.cross<T>(
    A : numluau.ndArray<T>,
    B : numluau.ndArray<T>
): number
```
given 2 ndArrays with ndim = 1, returns the result of the cross product between `A` and `B`.

# Parameters

## A : numluau.ndArray<T\>
The first ndArray.

## B : numluau.ndArray<T\>
The second ndArray.

# Returns -> `ndArray<T>`
Result of a cross product between `A` and `B`.