---
icon: octicons/note-16
---
<h1 class = "tsukuyomi-api-header" markdown> 
<span class="tsukuyomi-api-icon" markdown>:octicons-note-24:</span> 
<span class="tsukuyomi-api-name">Polynomial</span> 
</h1> 

A object that represents a polynomial.
 
---
## properties 
<h3> 
coef
<span class = "tsukuyomi-api-type"> : ndArray </span> 
</h3> 

the coefficients of the polynomial in ascending order of degree. 
<h3> 
domain
<span class = "tsukuyomi-api-type"> : {number} </span> 
</h3> 

the scaled domain of the polynomial 
<h3> 
window
<span class = "tsukuyomi-api-type"> : {number} </span> 
</h3> 

the scaled window of the polynomial 
<h3> 
symbol
<span class = "tsukuyomi-api-type"> : string </span> 
</h3> 

the symbol of the polynomial 
 
 
---
## methods 
<h3 markdown>
degree 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
Polynomial:degree(
	
): number
```

returns the degree of the polynomial.  
<h3 markdown>
cutdeg 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
Polynomial:cutdeg(
	degree : number
): Polynomial
```

returns a copy of the polynomial thats trimmed to the degree `degree`.  
<h3 markdown>
copy 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
Polynomial:copy(
	
): Polynomial
```

returns a copy of the polynomial.  
<h3 markdown>
deriv 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
Polynomial:deriv(
	
): Polynomial
```

returns the derivative of the polynomial.  
<h3 markdown>
integ 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
Polynomial:integ(
	
): Polynomial
```

returns the antiderivative of the polynomial.  
<h3 markdown>
trim 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
Polynomial:trim(
	
): Polynomial
```

returns a copy of the polynomial without leading `tol`s (tol being defaulted to 0).  
<h3 markdown>
companion 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
Polynomial:companion(
	
): ndArray
```

returns the companion matrix of the Polynomial.  
<h3 markdown>
roots 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
Polynomial:roots(
	
): ndArray
```

returns the roots the polynomial as a ndArray.  
 
 
