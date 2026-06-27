---
title: flatten
---

```luau
function numluau.flatten<T>(
   Target : numluau.ndArray<T>
): numluau.ndArray<T>
```
Given a ndArray, will return a version of that ndArray where its shape its ndim = 1.

# Parameters

### Target : numluau.ndArray<T\>
The ndArray being flattened.

# Returns -> `ndArray<T>`
A new 1 dimensional ndArray.