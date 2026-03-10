export type ndArray = {
    type : "ndArray",
    ndim : number,
    Offset : number,
    Buffer : {},
    Shape : {number},
    Strides : {number},

    copy : (ndArray) -> ndArray,
    view : (ndArray) -> ndArray,
}

return nil