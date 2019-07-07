export const INITIALIZE_USERS = 'INITIALIZE_USERS';

export interface IUser {
    name: string,
    email: string,
    id: string
}

export interface IUserStore {
    users: IUser[]
}

interface InitializeUsers {
    type: typeof INITIALIZE_USERS
    payload: IUserStore
}





export type UserActionTypes = InitializeUsers