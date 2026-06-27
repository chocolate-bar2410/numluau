---
title: dot
---

```luau
function numluau.linalg.dot<T>(
    A : numluau.ndArray<T>,
    B : numluau.ndArray<T>
): numluau.ndArray<T> | number
```
given 2 ndArrays with ndim = 1, returns the result of the dot product between `A` and `B`.

if the 2 ndArrays have ndim = 2, a matrix multiplication will be done instead.
if the 2 ndArrays have ndim = 0, a regular multiplication will be done instead.

# Parameters

## A : numluau.ndArray<T\>
The first ndArray.

## B : numluau.ndArray<T\>
The second ndArray.

# Returns -> `ndArray<T>`
Result of a dot product between `A` and `B`.