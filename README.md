<p align = "left">
    <img src="./gh-assets/numluau-dark-banner.svg#gh-dark-mode-only" alt="numluau" width=512 height=256>
    <img src="./gh-assets/numluau-light-banner.svg#gh-light-mode-only" alt="numluau" width=512 height=256>
</p>

<p align = "center">
    <a href = "https://chocolate-bar2410.github.io/numluau"><img src="https://img.shields.io/badge/documentation-here?style=for-the-badge&logo=Luau&logoColor=white&logoSize=auto&color=hsl(0%2C0%25%2C10%25)" alt="documentation"> </a>
    <a href = "https://pesde.dev/packages/chocolate_bar2410/numluau"><img src="https://img.shields.io/badge/pesde-v1.1.1-blue?style=for-the-badge&labelColor=hsl(0%2C0%25%2C10%25)&color=%23F19D1E" alt="pesde"> </a>
    <a href = "https://luaupm.com/package?name=chocolatebar2410%2Fnumluau"><img src="https://img.shields.io/badge/LPM-v1.1.1-blue?style=for-the-badge&labelColor=hsl(0%2C0%25%2C10%25)&color=%23e61048" alt="documentation"> </a>
</p>


## Numerical luau for all your scientific urges
numluau (numerical luau) is a scientific computing library designed to bring vectorised operations, matrix utilities and scientific Computing in general to luau programmers.

Create N-dimensional arrays & compute operations, aggregations, linear equations and so much more.

Features:
- N-Dimensional array objects.
- Linear algebra capabilities.
- Sophisticated broadcasting functions.

## installation

Installation can either be done using pesde or lpm.
```
pesde add chocolate_bar2410/numluau
```

```
lpm add chocolatebar2410/numluau
```

## example

```lua
local numluau = require("path.to.numluau")

-- create a ndarray using a table
local a : numluau.ndArray<number> = numluau.array({1,2,3,4,5})

print(a + 5) -- array([6 7 8 9 10])
```