---
title: reshape
---

```luau
function numluau.arange<T>(
    Target : numluau.ndArray<T>,
    Shape : {number}
): numluau.ndArray<T>
```
Given a `target` ndArray, returns a copy of that array with the shape `Shape`

# Parameters

### Target : numluau.ndArray<T\>
The ndArray being flattened.

### Shape : {number}
The shape of the new ndArray<>

# Returns -> `ndArray<T>`
A new ndArray with shape `shape`