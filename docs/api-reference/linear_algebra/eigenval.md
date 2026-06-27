---
title: eigenval
---

```luau
function numluau.linalg.eigenval<T>(
    A : numluau.ndArray<T>,
): numluau.ndArray<T>
```
Given a ndArray with ndim = 2, returns the eigen values of that ndArray as a ndArray. 
# Parameters

## A : numluau.ndArray<T\>
The target ndArray.

# Returns -> `ndArray<T>`
Result the Eigen values of `A`.