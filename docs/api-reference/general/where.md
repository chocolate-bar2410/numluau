---
title: where
---

```luau
function numluau.where<T>(
    Mask : types.ndArray<boolean>,
    Target : types.ndArray<T>,
    FillValue : T
) : types.ndArray<T>
```
Given a `Mask` and a `Target` ndArray, it will produce a new array.
Comparing the 2 arrays, places where the `Mask` is `true` will be untouched, places where the `Mask` is `false` will be replaced by `FillValue`

# Parameters

### Mask : types.ndArray<boolean\>
A ndArray containing booleans which is used to decided whether to fill or not.

### Target : types.ndArray<T\>
The array the `Mask` is being applied to.

### FillValue : T
The value thats used where a `Mask` is set to `false`.

# Returns -> `ndArray<T>`
A new ndArray containing the original items, with `FillValue` applied to where the `Mask` was false.