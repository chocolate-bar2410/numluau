---
icon: lucide/rocket
title: polynomial
description: polynomial module tutorial
---
Polynomials are objects that represent expressions like $x^2+6x+9$.  
Where the expression its a series of coefficients using the "standard" power series as its basis.

Polynomial objects in numluau are a conveniance class that allows you to perform algebraic, differential and integral operations on that series.

Each coefficient is sorted in ascending power, so a polynomial like $1x^2+2x+3$ is implemented as:

```luau
const poly = numluau.polynomial({3,2,1})
```

## evaluation

we can treat polynomials as functions, where we can subsituite x for a given value.

```luau
const f = numluau.polynomial({9,6,1})
const A = f(5) -- 64

const B = f(1,2,3,4,5) -- array([16 25 36 49 64])
const C = f(numluau.linspace(-2,2,10)) -- array([1 2.1 3.6 5.4 7.7 10 13 17 21 25])
```

## operations

### differentiation & integration
Unlike `numluau.gradient()` or `numluau.cumsum()` which preform integration and differentiation using numerical methods.
We can do these same operations on polynomials algebraically.

=== "algebraically"
    ```luau
    local f = numluau.polynomial({0,0,1}) -- f(x) = x²
    local x = numluau.linspace(-2,2,10)

    local df = f:deriv() -- f'(x) = 2x
    local dy = df(x) -- array([-4 -3.1 -2.2 -1.3 -0.44 0.441.3 2.2 3.1 4])
    ```

=== "numerically"
    ```luau
    local x = numluau.linspace(-2,2,10)
    local df = numluau.gradient(x ^ 2) -- array([-1.6 -1.4 -0.99 -0.59 -0.2 0.2 0.59 0.99 1.4 1.6])
    ```

While doing it numerically looks simpler, polynomial differentiation allows us to evaluate the derivative at a single point.
`numluau.gradient` cant do this as it relies on there being multiple values.

!!! info
    numerical methods are only approximations to the derivative, polynomials give the exact derivative function.

```luau
local f = numluau.polynomial({0,0,1}) -- f(x) = x²
local df = f:deriv()

df(5)   -- 10
df(512) -- 1024
df(-20) -- -40
```

`polynomial:integ` also works the same way, instead if finds the anti derivative of the polynomial.
    ```luau
    local f = numluau.polynomial({0,0,2}) -- f(x) = x²
    local x = numluau.linspace(-2,2,10)

    local F = f:integ() -- F(x) = x^3 / 3
    local Y = F(x)
    ```

### arithmetic
We can also do polynomial arithmetic using the standard +-/* etc. operations

```luau
local polyA : numluau.Polynomial = numluau.polynomial({9,6,1})
local polyB : numluau.Polynomial = numluau.polynomial({3,1})

print(polyA + polyB)  -- 12 + 7x + 1x^2
print(polyA - polyB)  -- 6 + 5x + 1x^2
print(polyA * polyB)  -- 27 + 27x + 9x^2 + 1x^3
print(polyA // polyB) -- 3 + 1x

print(polyA * 2) -- 18 + 12x + 2x^2
print(polyA / 2) -- 4.5 + 3x + 0.5x^2
```

## interpolation
In data science we might have a collections of points, we may want to fit a function to those points.
This allows us to notice trends and interpolate/extrapolate missing data.

In numluau this is done using `numluau.polynomial.fit()`.

```luau
local x = numluau.array({1,2,3,4,5,6})
local y = numluau.array({2,4,6,8,10,12})

local fitted = numluau.polynomial.fit(y,x,1) -- 1.3 + 2.72x
```

we can raise the degree to get a tighter fit
!!! danger
    While higher degrees can give you a more exact fit, this can lead to overfitting.

```luau
local x = numluau.array({-4,-3,-2,-1,0,1,2,3,4,5})
local y = x * 2

local fitted = numluau.polynomial.fit(x,y,2) -- -0.02 + 1.73x - 0.02x^2
``` 

## solving polynomial equations

If we had a equation like $x^2-6x+9=0$, we can simply just use the quadratic formula to find its roots.

```luau
local a = 1
local b = -6
local c = 9

local x0 = (-b + math.sqrt(b^2 - 4 * a * c)) / (2 * a) -- 3
local x1 = (-b - math.sqrt(b^2 - 4 * a * c)) / (2 * a) -- 3
```

but for an equation like $x^3+9x^2+27x+27=0$ or even $x^4-10x^3+35x^2-50x+24=0$, you'd need more complicated methods for solving these equations.  
numluau solves this by using `polynomial:roots()`.

```luau
local poly_A = numluau.polynomial({27,27,9,1})
local result_A = poly_A:roots() -- array([-3 -3 -3])

local poly_B = numluau.polynomial({24,-50,35,-10,1})
local result_B = poly_B:roots() -- array([4 3 2 1])
```
