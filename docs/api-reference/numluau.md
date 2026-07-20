---
icon: octicons/note-16
---
<h1 class = "tsukuyomi-api-header" markdown> 
<span class="tsukuyomi-api-icon" markdown>:octicons-note-24:</span> 
<span class="tsukuyomi-api-name">numluau</span> 
</h1> 

The numluau library. 
 
---

### constructors

## methods 
<h4 markdown>
arange 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h4>
```luau
numluau.arange(
	start : number,
	stop : number?
): ndArray
```

creates a new ndArray containing consecutive numbers from start -> stop
if stop is not given, the range will be 1 -> start  

  
<h4 markdown>
linspace 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h4>
```luau
numluau.linspace(
	start : number,
	stop : number?,
	num : number?
): ndArray
```

creates a new ndArray containing `num` between start - stop
if stop is not given, the range will be 1 -> start
`num` defaults to 50  
 
<h4 markdown>
ones 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h4>
```luau
numluau.ones(
	... : number
): ndArray
```

creates a new ndArray of exclusively ones, using the arguments provided for the shape.  
<h4 markdown>
array 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h4>
```luau
numluau.array(
	data : : {any}
): ndArray
```
  
Constructs a new ndArray from a nested table.  
<h4 markdown>
zeros 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h4>
```luau
numluau.zeros(
	... : number
): ndArray
```

creates a new ndArray of exclusively zeroes, using the arguments provided for the shape.
  
<h4 markdown>
where 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h4>
```luau
numluau.where(
	Mask : ndArray,
	Target : ndArray,
	FillValue : any
): ndArray
```

Given a `Mask` and a `Target` ndArray, it will produce a new array.
Comparing the 2 arrays, places where the `Mask` is `true` will be untouched, places where the `Mask` is `false` will be replaced by `FillValue  
  
<h4 markdown>
reshape 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h4>
```luau
numluau.reshape(
	Target : ndArray,
	Shape : {number}
): ndArray
```

Returns a copy of the target ndArray with the Shape provided.  
 
<h4 markdown>
flatten 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h4>
```luau
numluau.flatten(
	Target : ndArray
): ndArray
```

Returns a copy of the target ndArray as a flat 1d ndArray.  
<h4 markdown>
meshgrid 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h4>
```luau
numluau.meshgrid(
	X : ndArray,
	Y : ndArray
): (ndArray,ndArray)
```

Given two 1-Dimensional ndArrays, will produce two 2-Dimensional ndArrays.
The ndArrays will have the dimensions of n x m
where n is the length of `X`, and m is the length of `Y`  

<h4 markdown>
vander 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h4>
```luau
numluau.vander(
	Target : ndArray,
	col_num : number
): ndArray
```

returns the vandermonde matrix of the target ndarray.  

---

### calculus

<h4 markdown>
diff 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h4>
```luau
numluau.diff(
	array : ndArray,
	axis : number?
): ndArray
```

computes the numerical difference between 2 values across an axis
axis defaults to 0  
<h4 markdown>
gradient 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h4>
```luau
numluau.gradient(
	array : ndArray,
	spacing : types.ndArray<T>? | {types.ndArray<T>?} | number?,,
	axis : number?
): (ndArray) | (...ndArray)
```

computes the gradients between 2 points numerically across an axis
spacing can either be a number, ndArray or a table of ndArrays
if no axis is provided and you've inputed multiple ndArrays for spacing.
it will output multiple ndArrays representing gradients across multiple spacing ndArrays.  
<h4 markdown>
cumsum 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h4>
```luau
numluau.cumsum(
	array : ndArray,
	axis : number?
): ndArray
```

computes the cumulative sum between 2 values across an axis
axis defaults to 0 
<h4 markdown>
cumprod 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h4>
```luau
numluau.cumprod(
	array : ndArray,
	axis : number?
): ndArray
```

computes the cumulative product between 2 values across an axis
axis defaults to 0  

---

### logical operators

<h4 markdown>
logical_and 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h4>
```luau
numluau.logical_and(
	x1 : ndArray,
	x2 : ndArray
): ndArray
```

Creates a boolean ndArray by applying a logical `and` between x1 and x2  
<h4 markdown>
logical_or 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h4>
```luau
numluau.logical_or(
	x1 : ndArray,
	x2 : ndArray
): ndArray
```

Creates a boolean ndArray by applying a logical `or` between x1 and x2
<h4 markdown>
logical_xor 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h4>
```luau
numluau.logical_xor(
	x1 : ndArray,
	x2 : ndArray
): ndArray
```

Creates a boolean ndArray by applying a logical `xor` between x1 and x2  
<h4 markdown>
logical_not 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h4>
```luau
numluau.logical_not(
	x1 : ndArray
): ndArray
```

Creates a boolean ndArray by applying a logical `not` on x1 

---

### comparisons

<h4 markdown>
greater 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h4>
```luau
numluau.greater(
	x1 : ndArray,
	x2 : ndArray
): ndArray
```

compares x1 and x2 and creates a boolean ndArray.
using the comparison x1 > x2.
<h4 markdown>
greater_equal 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h4>
```luau
numluau.greater_equal(
	x1 : ndArray,
	x2 : ndArray
): ndArray
```

compares x1 and x2 and creates a boolean ndArray.
using the comparison x1 ≥ x2.
<h4 markdown>
less 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h4>
```luau
numluau.less(
	x1 : ndArray,
	x2 : ndArray
): ndArray
```

compares x1 and x2 and creates a boolean ndArray.
using the comparison x1 < x2.

<h4 markdown>
less_equal 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h4>
```luau
numluau.less_equal(
	x1 : ndArray,
	x2 : ndArray
): ndArray
```

compares x1 and x2 and creates a boolean ndArray.
using the comparison x1 ≤ x2.

<h4 markdown>
equal 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h4>
```luau
numluau.equal(
	x1 : ndArray,
	x2 : ndArray
): ndArray
```

compares x1 and x2 and creates a boolean ndArray.
using the comparison x1 = x2.
<h4 markdown>
not_equal 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h4>
```luau
numluau.not_equal(
	x1 : ndArray,
	x2 : ndArray
): ndArray
```

compares x1 and x2 and creates a boolean ndArray.
using the comparison x1 ≠ x2.

---

### aggregations

<h4 markdown>
sum 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h4>
```luau
numluau.sum(
	array : ndArray,
	axis : number
): ndArray
```
Applies a sum aggregation either across the entire ndArray or across a specified axis

<h4 markdown>
prod 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h4>
```luau
numluau.prod(
	array : ndArray,
	axis : number
): ndArray
```
Applies a prod aggregation either across the entire ndArray or across a specified axis

<h4 markdown>
min 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h4>
```luau
numluau.min(
	array : ndArray,
	axis : number
): ndArray
```
Creates a ndarray of the minimum values of either the entire ndArray or over a specified axis

<h4 markdown>
max 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h4>
```luau
numluau.max(
	array : ndArray,
	axis : number
): ndArray
```
Creates a ndarray of the maximum values of either the entire ndArray or over a specified axis

<h4 markdown>
mean 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h4>
```luau
numluau.mean(
	array : ndArray,
	axis : number
): ndArray
```
Creates a ndarray of the mean values of either the entire ndArray or over a specified axis

<h4 markdown>
var 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h4>
```luau
numluau.var(
	array : ndArray,
	axis : number
): ndArray
```
Creates a ndarray of the variances across either the entire ndArray or over a specified axis

<h4 markdown>
std 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h4>
```luau
numluau.std(
	array : ndArray,
	axis : number
): ndArray
```
Creates a ndarray of the standard deviations across either the entire ndArray or across a specified axis

### miscellaneous

<h4 markdown>
set_printoptions
<span class = "tsukuyomi-api-type"> -> () </span> 
</h4>
```luau
numluau.set_printoptions(args: {
	suppress: boolean,
	precision: number,
	threshold: number,
	edgeitems: number,
	linewidth: number,
})
```

configures the prettyprint of the library.

|property	 | description 																			 | default value|
|------------|---------------------------------------------------------------------------------------|--------------|
| suppress   | suppresses small numbers 															 | false   		|
| precission | the precission of the numbers 														 | 8 d.p   		|
| threshold  | the number of values, a ndarray it can have per row before its tostring is truncated. | 100 	   		|
| edge items | the ammount of items that show up when a ndarray's tostring is truncated. 			 | 3 	   		|
| line width | the max ammount of characters before a ndarray's tostring is wrapped around. 		 | 75	   		|