---
icon: octicons/dice-24
title: random
description: random module tutorial
---

When working with quantative finance or machine learning, you may want to generate a set of random numbers.
At the moment luau's solution to this is `math.random` and `math.randomseed`.

```luau
math.randomseed(12)
local random_num = math.random() -- random number between 0 - 1 with a seed of 12
```

The problem with this is that this only works for uniform distributions, using a predetermined generator and can only generate 1 value at a time.
numluau solves this with its `random` module.

to do the equivalent of the above code in numluau you can do:
```luau
local rng = numluau.random.default_rng(12)
local random_num = rng:random()
```

you can also define a shape and it will output a array of values.

```luau
local rng = numluau.random.default_rng(12)
local random_array = rng:random(2,2) -- 2x2 array of random values
```

## uniform distribution

The main distribution numluau uses is the `uniform` `distribution`.
Every number has a equal chance to be picked.

```luau
local rng = numluau.random.default_rng()

-- like before but you can pick a range of values
local random_uniform = rng:uniform(1,10,{2,2})

-- same as random uniform but using integers
local random_integers = rng:integers(1,10,{2,2})
```

## other distributions
This may be fine for some usecases, but most fields want more than just a uniform distribution.
Many fields often will require other distributions like `normal`, `binomial` or `gamma` distributions.

Quants would want `lognormal` distributions for black scholes equations.
Astronomers would need `poission` distributions for counting photons from stars.

numluau provides access to these distributions for use.

```luau
local rng = numluau.random.default_rng()

local mean = 0
local stand_dev = 1

local random_normal = rng:normal(mean,stand_dev,{3,3})

local scale = 2
local random_exponential = rng:exponential(scale,{3,3})
```

## bit generators
By default numluau uses the `PCGXSH` generator, a 32bit version of the PCG64 random generator.
But this can be swapped out for other `bit generators` numluau provides.

generators that are provided:

- XOSHIRO128
- SFC32
- Philox
- JSF32
- PCGXSH (default)

```luau
local bit_gen = numluau.random.XOSHIRO128()
local rng = numluau.random.new(bit_gen)

-- generates a 5x3 array of integers using XOSHIRO128
local random_integers = rng:integers(1,10,{5,3})
```

## Shuffles and Choosing
While generating values is necessary, the random module also has other methods for randomness.

### Shuffles
`rng:shuffle` and `rng:permutation` both allow you to shuffle a array of numbers.
shuffle is for shuffling implace, while permutation create a shuffled copy of a array.
=== "rng:shuffle()"

    ```luau
    local rng = numluau.random.default_rng()
    local items = numluau.array({1,2,3,4,5})

    rng:shuffle(items)

    print(items) -- array([3,4,2,1,5])
    ```
=== "rng:permutation()"

    ```luau
    local rng = numluau.random.default_rng()
    local items = numluau.array({1,2,3,4,5})

    local permute = rng:permutation(items)

    print(permute) -- array([3,4,2,1,5])
    ```

By default it will swap the items around the top axis, this can also be changed as a parameter.
```luau
local rng = numluau.random.default_rng()
local items = numluau.array({
    {1,2,3,4},
    {5,6,7,8},
    {9,10,11,12},
})

print(rng:permutation(items))   -- swaps columns
print(rng:permutation(items,0)) -- swaps rows

```
``` title="output"
array([
  [5 6 7 8]
  [9  10 11 12]
  [1 2 3 4]
])
array([
  [2 3 1 4]
  [6 7 5 8]
  [10 11 9  12]
])
```


### Choosing
`rng:choice()` allows you to randomly pick items out of another array.

```luau
local rng = numluau.random.default_rng()
local fruits = numluau.array({"🍎","🍊","🥥","🍌","🍍"})

-- a single random fruit
local single_fruit = rng:choice(fruits)

-- 5x3 array of random fruits
local fruit_array = rng:choice(fruits,{5,3}) 
```
