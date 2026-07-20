---
icon: octicons/note-16
---
<h1 class = "tsukuyomi-api-header" markdown> 
<span class="tsukuyomi-api-icon" markdown>:octicons-note-24:</span> 
<span class="tsukuyomi-api-name">ndArray</span> 
</h1> 

ndArrays represent an nth dimensional array that you can perform vectorised operations on. 

---

## properties 
<h3> 
Buffer
<span class = "tsukuyomi-api-type"> : {T} </span> 
</h3> 

A flat table containing the array's values. 
<h3> 
ndim
<span class = "tsukuyomi-api-type"> : number </span> 
</h3> 

The dimension number of the array. 
<h3> 
Shape
<span class = "tsukuyomi-api-type"> : {number} </span> 
</h3> 

The table that defines the dimensions of the array. 
<h3> 
Strides
<span class = "tsukuyomi-api-type"> : {number} </span> 
</h3> 

The table that defines how indices get converted into a flat index. 
<h3> 
Offset
<span class = "tsukuyomi-api-type"> : number </span> 
</h3> 

The offset where the first index begins. 
<h3> 
type
<span class = "tsukuyomi-api-type"> : "ndArray" </span> 
</h3> 

The type of the object, this being "ndArray" 
<h3> 
dtype
<span class = "tsukuyomi-api-type"> : string </span> 
</h3> 

The datatype of the values the array is holding. 
 
 
---
## methods 
<h3 markdown>
copy 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
ndArray:copy(
	
): ndArray
```

creates a new copy of the original ndArray.  
<h3 markdown>
view 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
ndArray:view(
	
): ndArray
```

creates a new view of the original ndArray.  
<h3 markdown>
reshape 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
ndArray:reshape(
	... : number
): ndArray
```

creates a new view of the original ndArray using the arguments provided for the shape.  
<h3 markdown>
flatten 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
ndArray:flatten(
	
): ndArray
```

creates a new view of the original ndArray as a flat array.  
<h3 markdown>
eye 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
ndArray:eye(
	
): ndArray
```

returns the identity matrix of the ndArray.
!!!warning
ndArray must be have ndim = 2  
<h3 markdown>
transpose 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
ndArray:transpose(
	
): ndArray
```

creates a new view of the original ndArray which is transposed.  
<h3 markdown>
item 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
ndArray:item(
	... : number
): ndArray
```

gets the value from the ndArray using the indices provided.
0d ndArrays will just return the value they're holding.  
<h3 markdown>
toflatlist 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
ndArray:toflatlist(
	... : number
): {T}
```

returns a flat table of elements from the ndArray, with respect to its shape, stride and offset.  
<h3 markdown>
swap 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
ndArray:swap(
	index1 : number,
	index2 : number,
	axis : number
): ndArray
```

does a implace swap across an axis between the values at index1 and index2  
 
 
