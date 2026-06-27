---
title: NdArray
---

```luau
export type ndArray<T>{
    type : "ndArray",
    dtype : string,
    ndim : number,
    Offset : number,
    Buffer : {T},
    Shape : {number},
    Strides : {number},

    copy : (ndArray<T>) -> ndArray<T>,
    view : (ndArray<T>) -> ndArray<T>,
    reshape : (ndArray<T>,...number) -> ndArray<T>,
    flatten : (ndArray<T>,...number) -> ndArray<T>,
    eye : (ndArray<T>) -> ndArray<number>,
    transpose : (ndArray<T>) -> ndArray<T>,
    item : (ndArray<T>,...number) -> T
}
```

# members

### type : "ndArray"
A value used to tell if a value is a ndArray.

### dtype : string
The data type of the items of the ndArray.

### ndim : number
The dimension of the ndArray.

### Offset : number
A table that determins the dimensions of the ndArray.

### Buffer : {T\}
A table that describes how to index the ndArray.

### Shape : {number\}
The raw table that holds the data.

### Strides : {number\}
Determines the first item of the ndArray.


# methods

### copy : (ndArray<T\>) -> ndArray<T\>
returns a copy of the ndArray.

### view : (ndArray<T\>) -> ndArray<T\>
returns a view of the ndArray.

### reshape : (ndArray<T\>,...number) -> ndArray<T\>
returns a view of the ndArray with the shape {`...`}

### flatten : (ndArray<T\>,...number) -> ndArray<T\>
returns a view of the ndArray with ndim = 1.

### eye : (ndArray<T\>) -> ndArray<number>
returns the identity of the ndArray.

### transpose : (ndArray<T\>) -> ndArray<T\>
returns a view of the ndArray with its shape reversed.

### item : (ndArray<T\>,...number) -> T
Indexes the ndArray using the arguements `...`.
If ndim = 0 then it just returns the value stored inside it.