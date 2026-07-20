---
icon: octicons/note-16
---
<h1 class = "tsukuyomi-api-header" markdown> 
<span class="tsukuyomi-api-icon" markdown>:octicons-note-24:</span> 
<span class="tsukuyomi-api-name">linalg</span> 
</h1> 

the linear algebra submodule for numluau. 
 
---
## methods 
<h3 markdown>
matmul 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
linalg.matmul(
	A : ndArray,
	B : ndArray
): ndArray
```

returns the result of a matrix multiplication between A and B
if A is ndim = 2 and B is ndim = 1 then a matrix-vector multiplication is done instead.  
<h3 markdown>
lu 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
linalg.lu(
	matrix : ndArray
): (ndArray, ndArray, {number}, number)
```

preforms a LU decomposition on the matrix, producing values:
- lower triangular ndArray (L).
- upper triangular ndArray (U).
- permutation table.
- swap count.
given matrix = LU  
<h3 markdown>
det 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
linalg.det(
	matrix : ndArray
): ndArray
```

returns the determinant of the matrix.  
<h3 markdown>
dot 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
linalg.dot(
	A : ndArray,
	B : ndArray
): ndArray
```

returns the dot product between A and B.  
<h3 markdown>
cross 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
linalg.cross(
	A : ndArray,
	B : ndArray
): ndArray
```

returns the cross product between A and B  
<h3 markdown>
qr 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
linalg.qr(
	matrix : ndArray
): (ndArray,ndArray)
```

Performs a QR decomposition on the matrix, returning a orthogonal matrix Q and a upper triangular matrix R.  
<h3 markdown>
eigenval 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
linalg.eigenval(
	matrix : ndArray
): ndArray
```

Returns the eigen values of the matrix.  
<h3 markdown>
eig 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
linalg.eig(
	matrix : ndArray
): (ndArray,ndArray)
```

returns the eigen values and eigen vectors of the matrix
the eigen vectors being given as a single 2d ndArray in column major order.  
<h3 markdown>
solve 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
linalg.solve(
	A : ndArray,
	B : ndArray
): ndArray
```

returns the solution to the equation $Ax = B$  
<h3 markdown>
norm 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
linalg.norm(
	matrix : ndArray,
	axis : ndArray,
	order : ndArray
): ndArray
```

Normalises a matrix across a axis
order = 1 does a manhattan normalisation
order = 2 does a euclidean normalisation
order defaults to 2
axis defaults to 0  
<h3 markdown>
svd 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
linalg.svd(
	matrix : ndArray
): (ndArray,ndArray,ndArray)
```

Performs a SVD decomposition, returning U, Vt and the matrix's singular values.  
<h3 markdown>
lstsq 
<span class = "tsukuyomi-api-type"> -> () </span> 
</h3>
```luau
linalg.lstsq(
	x : ndArray,
	y : ndArray,
	degree : number
): ndArray
```

Preforms a least squares fit on x and y, producing the coefficents of degree `degree` in descending order
degree defaults to 0.  
 
 
