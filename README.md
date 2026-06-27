# numLuau
numluau (numerical luau) is a scientific computing library designed to bring vectorised operations, matrix utilities and scientific computing in general to luau programmers.

create N-dimensional arrays & compute operations, aggregations, linear equations and so much more.

features:
- N-Dimensional array objects
- Linear algebra capabilities
- Sophisticated broadcasting functions

documentation: https://chocolate-bar2410.github.io/numluau/  
tutorials: https://chocolate-bar2410.github.io/numluau/tutorials/

# installation

its reccomended to install using pesde
```
pesde add chocolate_bar2410/numluau
```

# example

```lua
local numluau = require("path.to.numluau")

-- create a ndarray using a table
local a : numluau.ndArray<number> = numluau.array({1,2,3,4,5})

print(a + 5) -- array([6 7 8 9 10])
```