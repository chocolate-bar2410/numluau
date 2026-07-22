---
template: "home.html"
title: numluau
description: a scientific computing library
hide:
    - navigation
    - toc
---

<div id="numluau-home" markdown>
<section id="numluau-home-main" markdown>
<section id="numluau-home-inner" markdown>

# Numerical luau for all your scientific urges.
<p>
Numerical luau is a runtime agnostic library for safer, simpler code.
<p>
</p>
Bring scientific computing in a way easy to understand and predict.
Compress large computations filled with loops and table allocations into simple vectorised operations.
Prototype and Build mathematical models, for any tasks in a typesafe manner.
</p>
<p>
In Addition, numluau also comes with submodules for linear algebra, polynomials and randomness.
</p>

<p>
<nav> 
<a href = "./tutorials">Getting started guide </a>

</nav>
</p>

</section>
</section>

<aside id="numluau-home-scroll">
    scroll down for a quick overview.
</aside>

<section id="numluau-home-below" markdown>

<h2 class="first">Vectorised operations</h2>

Numeric luau introduces N-Dimensional arrays, Simple but allows you to simplify repetitive code.

---

Turn what would be tedious for loops, table allocations and indexing. <br>
Into a single addition.

=== "using arrays"
    ```luau hl_lines="5"
    local a = numluau.array({1,2,3,4,5})
    local b = numluau.array({10,20,30,40,50})

    local c = a + b
    print(c) -- array([11 22 33 44 55])
    ```
=== "using regular tables"
    ```luau hl_lines="5-7"
    local a = {1,2,3,4,5}
    local b = {10,20,30,40,50}

    local c = {}
    for i = 1,5 do
        c[i] = a[i] + b[i]
    end

    print(c) -- array([11 22 33 44 55])
    ```
<h2 class="second">Broadcasting</h2>

Want to multiply 2 arrays, they're sizes dont match. <br>
Well thats not going to stop you.

---

when performing arithmetic between 2 arrays, numluau will automatically stretch them to fit according to <a href="./tutorials/fundementals/arithmetic.md#broadcasting"> special rules </a>.

=== "code"
    ```luau
    local a = numluau.array({
        {1,2,3},
    })
    local b = numluau.array({
        {0, 0, 0},
        {10,10,10},
        {20,20,20},
        {30,30,30},
    })

    print(a * b)
    ```
=== "output"
    ```
    > array([
        [0 0 0]
        [10 20 30]
        [20 40 60]
        [30 60 90]
    ])
    ```


<h2 class="third">Index and slicing</h2>
If you need to only access only a section of the array.<br>
Simply slice the array just by indexing.

---

=== "code"
    ```luau
    local a = numluau.array({
        {1,2,3,4},
        {5,6,7,8},
        {9,10,11,12},
        {13,14,15,16},
    })

    print(a["1:2, 1:2"])
    print(a["1:2, 1:3:2"])
    ```
=== "output"
    ```
    > array([ 
        [1 2] 
        [5 6] 
    ])
    
    > array([ 
        [1 3] 
        [5 7] 
    ])
    ```
---

<h2> Interested? </h2>

If you want a more indepth tutorial Theres a comprehensive <a href="./tutorials"> beginner's tutorial </a> complete with examples and code.

</section>
</div>