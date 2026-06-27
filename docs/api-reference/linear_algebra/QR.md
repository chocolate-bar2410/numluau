---
title: qr
---

```luau
function numluau.linalg.qr<T>(
    A : numluau.ndArray<T>,
): (numluau.ndArray<T>,numluau.ndArray<T>)
```
given a ndArray with ndim = 2, returns a orthogonal ndArray (Q) and a upper triangular ndArray (R).
where A = QR

# Parameters

## A : numluau.ndArray<T\>
The target ndArray.

# Returns -> `(numluau.ndArray<T>, numluau.ndArray<T>)`
A orthogonal ndArray (Q) and a upper triangular ndArray (R).
where A = QR