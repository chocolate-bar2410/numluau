---
icon: octicons/note-16
---
<h1 class = "tsukuyomi-api-header" markdown> 
<span class="tsukuyomi-api-icon" markdown>:octicons-note-24:</span> 
<span class="tsukuyomi-api-name">Generator</span> 
</h1> 
 
---
## properties 
<h3> 
BitGenerator
<span class = "tsukuyomi-api-type"> : () -> number </span> 
</h3> 

The bit generator thats used to generate random numbers. 
<h3> 
type
<span class = "tsukuyomi-api-type"> : "Generator" </span> 
</h3> 

The type of the object, this being "Generator" 
 
 
---
## methods 
<h3 markdown>
random 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
Generator:random(
	
): Generator
```

Generates a ndArray of random values between 0 - 1.  
<h3 markdown>
integers 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
Generator:integers(
	min : number,
	max : number,
	shape : {number}
): ndArray
```

Generates a ndArray of random integers between min - max.  
<h3 markdown>
choice 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
Generator:choice(
	shape : {number},
	target : ndArray
): ndArray
```

Generates a ndArray of random values from a target array.  
<h3 markdown>
normal 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
Generator:normal(
	mean : number,
	std_dev : number,
	shape : {number}
): ndArray
```

Generates a ndArray of random values sampled from a normal distribution, defined by a mean and standard deviation.  
<h3 markdown>
lognormal 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
Generator:lognormal(
	mean : number,
	std_dev : number,
	shape : {number}
): ndArray
```

Generates a ndArray of random values sampled from a lognormal distribution, defined by a mean and standard deviation.  
<h3 markdown>
exponential 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
Generator:exponential(
	scale : number,
	shape : {number}
): ndArray
```

Generates a ndArray of random values sampled from a exponential distribution thats scaled.  
<h3 markdown>
gamma 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
Generator:gamma(
	alpha : number,
	scale : number,
	shape : {number}
): ndArray
```

Generates a ndArray of random values sampled from a gamma distribution, defined by ɑ and scale.  
<h3 markdown>
beta 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
Generator:beta(
	alpha : number,
	beta : number,
	shape : {number}
): ndArray
```

Generates a ndArray of random values sampled from a gamma distribution, defined by ɑ and β.  
<h3 markdown>
uniform 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
Generator:uniform(
	min : number,
	max : number,
	shape : {number}
): ndArray
```

Generates a ndArray of random values sampled from a uniform distribution between min - max.  
<h3 markdown>
poisson 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
Generator:poisson(
	lambda : number,
	shape : {number}
): ndArray
```

Generates a ndArray of random values sampled from a poisson distribution defined by λ.
with λ representing rate  
<h3 markdown>
binomial 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
Generator:binomial(
	trial_num : number,
	probability : number,
	shape : {number}
): ndArray
```

Generates a ndArray of random values sampled from a binomial distribution defined by a trial number and probability.  
<h3 markdown>
shuffle 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
Generator:shuffle(
	target : ndArray,
	axis : number
): ndArray
```

Performs a inplace shuffle on a target ndArray across an axis.  
<h3 markdown>
permutation 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
Generator:permutation(
	target : ndArray | number,
	axis : number
): ndArray
```

returns a result of shuffle on a clone of the target ndArray across an axis.  
 
 
