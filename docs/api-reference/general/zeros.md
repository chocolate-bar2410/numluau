---
title: zeros
---

```luau
function numluau.zeros<number>(
    ... : number
): numluau.ndArray<number>
```
Will return a new ndArray filled with zeroes.
The returned ndArray will have a shape defined by the arguements provided.

# Parameters

... : number
the values defining the shape of the ndArray

# Returns -> `ndArray<number>`
A new ndArray filled with zeroes, with a shape {...}