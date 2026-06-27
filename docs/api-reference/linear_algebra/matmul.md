---
title: matmul
---

```luau
function numluau.linalg.matmul<T>(
    A : numluau.ndArray<T>,
    B : numluau.ndArray<T>
): numluau.ndArray<T>
```
given 2 ndArrays with ndim = 2, returns the result of a matrix multiplication between `A` and `B`.
# Parameters

## A : numluau.ndArray<T\>
The first ndArray.

## B : numluau.ndArray<T\>
The second ndArray.

# Returns -> `ndArray<T>`
Result of a matrix multiplication between `A` and `B`.