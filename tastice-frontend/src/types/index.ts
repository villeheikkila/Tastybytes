export interface IProduct {
    name: string,
    producer: string,
    type: string,
    id: string
}

export interface IUser {
    name: string,
    email: string,
    id: string
}

export interface IUserList {
    users: IUser[]
}

export interface IProductList {
    products: IProduct[]
}