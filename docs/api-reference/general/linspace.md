---
title: linspace
---

```luau
function numluau.linspace<number>(
    start : number,
    stop : number?,
    num : number?
): numluau.ndArray<number>
```
Given 3 values, returns a new ndArray, containing `num` items, from start -> stop.

# Parameters

### start : number
the first value of the ndArray

### stop : number?
The last value of the ndArray.
If this value is nil, the value will become the start value, and the start value will become 1.

### num : number?
The number of elements in the ndArray

# Returns -> `ndArray<number>`
A new ndArray containing `num` items from start -> stop.