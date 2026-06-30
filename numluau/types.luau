export type ndArray<T> = setmetatable<{
    type : "ndArray",
    dtype : string,
    ndim : number,
    Offset : number,
    Buffer : {T},
    Shape : {number},
    Strides : {number},

    copy : (self : ndArray<T>) -> ndArray<T>,
    view : (self : ndArray<T>) -> ndArray<T>,
    reshape : (self : ndArray<T>,...number) -> ndArray<T>,
    flatten : (self : ndArray<T>,...number) -> ndArray<T>,
    eye : (self : ndArray<T>) -> ndArray<number>,
    transpose : (self : ndArray<T>) -> ndArray<T>,
    item : (self : ndArray<T>,...number) -> T,
    toflatlist : (self : ndArray<T>) -> {T},
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
    __iter : (self : ndArray<T>) -> () -> (number,T),
    __len : (self : ndArray<T>) -> number
}>

export type Version = {
    major : number, 
    minor : number
}

export type Generator = {
    BitGenerator : () -> number,
    rand : (self : Generator,... number) -> ndArray<number>,
    integers : (self : Generator,min : number, max : number, shape : {number}) -> ndArray<number>,
    
    normal : (self : Generator,mean : number,std_dev : number,shape : {number}) -> ndArray<number>,
    uniform : (self : Generator,min : number, max : number, shape : {number}) -> ndArray<number>,
}

return nil