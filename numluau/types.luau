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
    swap : (self : ndArray<T>,index1 : number,index2 : number,axis : number) -> ()
},{
    __index : (ndArray<T>,index : number | ndArray<boolean> | string) -> T | ndArray<T>,
    __newindex : (ndArray<T>,index : number | string,value : T) -> (),
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
    type : "Generator",
    BitGenerator : () -> number,
    rand : (self : Generator,... number) -> ndArray<number>,
    integers : (self : Generator,min : number, max : number, shape : {number}) -> ndArray<number>,
    
    normal : (self : Generator,mean : number,std_dev : number,shape : {number}) -> ndArray<number>,
    lognormal : (self : Generator,mean : number,std_dev : number,shape : {number}) -> ndArray<number>,
    exponential : (self : Generator,scale : number,shape : {number}) -> ndArray<number>,
    gamma : (self : Generator,alpha : number,scale : number,shape : {number}) -> ndArray<number>,
    beta : (self : Generator,alpha : number,beta : number,shape : {number}) -> ndArray<number>,
    
    uniform : (self : Generator,min : number, max : number, shape : {number}) -> ndArray<number>,
    
    poisson : (self : Generator,lambda : number,shape : {number}) -> ndArray<number>,
    binomial : (self : Generator,trial_num : number,probability : number,shape : {number}) -> ndArray<number>,

    choice : <T>(self : Generator,target : ndArray<T>,shape : {number}) -> ndArray<T>,

    shuffle : <T>(self : Generator,target : ndArray<T>,axis : number) -> (),
    permutation : <T>(self : Generator,target : ndArray<T> | number,axis : number) -> ()
}

export type Polynomial = setmetatable<{
    coef : ndArray<number>,
    domain : {number},
    window : {number},
    symbol : string,
    degree : (self : Polynomial) -> number,
    cutdeg : (self : Polynomial,degree : number) -> Polynomial,
    copy : (self : Polynomial) -> Polynomial,
    deriv : (self : Polynomial) -> Polynomial,
    integ : (self : Polynomial) -> Polynomial,
    trim : (self : Polynomial) -> Polynomial,
    roots : (self : Polynomial) -> ndArray<number>,

},{
    __call : (self : Polynomial, value : ndArray<number> | number) -> ndArray<number> | number,
    __tostring : (self : Polynomial) -> string,
}>


return nil