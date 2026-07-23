---
icon: octicons/note-16
---
<h1 class = "tsukuyomi-api-header" markdown> 
<span class="tsukuyomi-api-icon" markdown>:octicons-note-24:</span> 
<span class="tsukuyomi-api-name">polynomial</span> 
</h1> 

The polynomial module of numluau. 
 
---
## methods 
<h3 markdown>
fromroots 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
polynomial.fromroots(
	roots : {number}
): Polynomial
```

constructs a polynomial from its roots.  
<h3 markdown>
set_printstyle 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
polynomial.set_printstyle(
	printstyle : "ascii" | "unicode"
): Polynomial
```

set whether to use ascii or unicode characters when stringifying polynomials.  
 
 
