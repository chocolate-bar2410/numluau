---
title: arange
---

```luau
function numluau.arange<number>(
    start : number,
    stop : number?
): numluau.ndArray<number>
```
given a start and a option stop value, returns a ndArray containing numbers from start -> stop

# Parameters

### start : number
the first value of the ndArray

### stop : number?
The last value of the ndArray.
If this value is nil, the value will become the start value, and the start value will become 1.

# Returns -> `ndArray<number>`
A new ndArray, who's value ranges from start -> stop.