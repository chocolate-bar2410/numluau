---
title: solve
---

```luau
function numluau.linalg.solve<T>(
    A : numluau.ndArray<T>,
    C : numluau.ndArray<T>,
): (numluau.ndArray<T>,numluau.ndArray<T>)
```
given a Coefficent ndArray (A), and a ordinate ndArray (C), returns the solution the equation:

Ax = C

# Parameters

## A : numluau.ndArray<T\>
The Coefficent ndArray with ndim = 2.

## C : numluau.ndArray<T\>
The Ordinate ndArray with ndim = 1.

# Returns -> `(numluau.ndArray<T>)`
the solution the equation:

Ax = C