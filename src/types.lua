export type ndArray<T> = {
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
}

return nil