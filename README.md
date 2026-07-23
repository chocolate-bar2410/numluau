<p align = "left">
    <img src="./gh-assets/numluau-dark-banner.svg#gh-dark-mode-only" alt="numluau" width=512 height=256>
    <img src="./gh-assets/numluau-light-banner.svg#gh-light-mode-only" alt="numluau" width=512 height=256>
</p>

## Numerical luau for all your scientific urges
numluau (numerical luau) is a scientific computing library designed to bring vectorised operations, matrix utilities and scientific Computing in general to luau programmers.

Create N-dimensional arrays & compute operations, aggregations, linear equations and so much more.

Features:
- N-Dimensional array objects.
- Linear algebra capabilities.
- Sophisticated broadcasting functions.

documentation: https://chocolate-bar2410.github.io/numluau

## installation

Its reccomended to install using pesde.
```
pesde add chocolate_bar2410/numluau
```

## example

```lua
local numluau = require("path.to.numluau")

-- create a ndarray using a table
local a : numluau.ndArray<number> = numluau.array({1,2,3,4,5})

print(a + 5) -- array([6 7 8 9 10])
```