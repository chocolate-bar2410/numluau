---
icon: octicons/note-16
---
<h1 class = "tsukuyomi-api-header" markdown> 
<span class="tsukuyomi-api-icon" markdown>:octicons-note-24:</span> 
<span class="tsukuyomi-api-name">random</span> 
</h1> 

the random submodule of numluau. 
 
---
## methods 
<h3 markdown>
default_rng 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
random.default_rng(
	seed : number
): Generator
```

Constructs a new `Generator` object using the default bit generator (PCGXSH) with the seed provided.  
<h3 markdown>
XOSHIRO128 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
random.XOSHIRO128(
	seed : number
): () -> number
```

returns a bit generator that produces numbers using XOSHIRO128.  
<h3 markdown>
generator 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
random.generator(
	bit_generator : () -> number
): Generator
```

Constructs a new `Generator` object using the bit generator provided.  
<h3 markdown>
SFC32 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
random.SFC32(
	seed : number
): () -> number
```

returns a bit generator that produces numbers using SFC32.  
<h3 markdown>
Philox 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
random.Philox(
	seed : number
): () -> number
```

returns a bit generator that produces numbers using Philox.  
<h3 markdown>
JSF32 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
random.JSF32(
	seed : number
): () -> number
```

returns a bit generator that produces numbers using JSF32.  
<h3 markdown>
PCGXSH 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
random.PCGXSH(
	seed : number
): () -> number
```

returns a bit generator that produces numbers using PCGXSH.  
 
 
