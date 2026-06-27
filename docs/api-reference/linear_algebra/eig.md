---
title: eig
---

```luau
function numluau.linalg.eigenval<T>(
    A : numluau.ndArray<T>,
): (numluau.ndArray<T>,numluau.ndArray<T>)
```
Given a ndArray with ndim = 2, returns the eigen values of that ndArray as well its eigen vectors.
Both as a ndArray.

the Eigen vectors will be represented as a column major 2-Dimensional ndArray.

# Parameters

## A : numluau.ndArray<T\>
The target ndArray.

# Returns -> `number`
Result the Eigen values and Eigen vectors of `A`.