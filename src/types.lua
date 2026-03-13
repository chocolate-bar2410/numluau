export type ndArray = {
    type : "ndArray",
    dtype : string,
    ndim : number,
    Offset : number,
    Buffer : {},
    Shape : {number},
    Strides : {number},

    copy : (ndArray) -> ndArray,
    view : (ndArray) -> ndArray,
    reshape : (ndArray,...number) -> ndArray,
    flatten : (ndArray,...number) -> ndArray,
}

return nil