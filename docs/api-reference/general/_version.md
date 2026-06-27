---
title: version
---

```luau
export type numluau.Version{
    major : number, 
    minor : number
}
```
given a nested table, returns a ndArray.
if data is not a table, return a 0d ndArray.

# Members

### major : number
The major version number.
Two verisons sharing the same major version number should be expected to be compatible.

### minor : number
The minor version number.
Describes versions that are non breaking. 

# Returns -> `ndArray<T>`
A new ndArray that be used by the developer.