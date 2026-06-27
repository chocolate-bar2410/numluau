---
title: lu
---

```luau
function numluau.linalg.lu<T>(
    A : numluau.ndArray<T>,
): (numluau.ndArray<T>,numluau.ndArray<T>,{number},number)
```
given a ndArray with ndim = 2, returns 
- lower triangular ndArray (L).
- upper triangular ndArray (U).
- permutation table.
- swap count.

where A = LU

# Parameters

## A : numluau.ndArray<T\>
The target ndArray.

# Returns -> `(numluau.ndArray<T>, numluau.ndArray<T>, {number}, number)`
- lower triangular ndArray (L).
- upper triangular ndArray (U).
- permutation table.
- swap count.

where A = LU