---
title: array
---

```luau
function numluau.array<T>(
    data : {T} | T
): numluau.ndArray<T>
```
given a nested table, returns a ndArray.
if data is not a table, return a 0d ndArray.

# Parameters

### data : {T\}
the table thats used to initalise a new `ndArray`

# Returns -> `ndArray<T>`
A new ndArray that be used by the developer.