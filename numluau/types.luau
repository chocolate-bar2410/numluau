export type ndArray<T> = setmetatable<{
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
},{
    __index : (ndArray<T>,index : number | ndArray<boolean> | string) -> (),
    __newindex : () -> (),
    __tostring : (ndArray<T>) -> string,
    __add : (ndArray<T>,value : number | ndArray<T>) -> ndArray<T>,
    __sub : (ndArray<T>,value : number | ndArray<T>) -> ndArray<T>,
    __mul : (ndArray<T>,value : number | ndArray<T>) -> ndArray<T>,
    __div : (ndArray<T>,value : number | ndArray<T>) -> ndArray<T>,
    __idiv : (ndArray<T>,value : number | ndArray<T>) -> ndArray<T>,
    __pow : (ndArray<T>,value : number | ndArray<T>) -> ndArray<T>,
    __mod : (ndArray<T>,valu : number | ndArray<T>) -> ndArray<T>,
    __unm : (ndArray<T>,value : number | ndArray<T>) -> ndArray<T>,
}
>
return nil