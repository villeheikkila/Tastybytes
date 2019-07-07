import { IUser, UserActionTypes } from './types'

export interface IUserStore {
    users: IUser[]
}

const userState: IUserStore = {
    users: []
}

export const userReducer = (state = userState, action: UserActionTypes): IUserStore => {
    console.log("action", action)
    switch (action.type) {
        case 'INITIALIZE_USERS':
            console.log('action.data: ', action.payload);
            return action.payload
        default:
            return state
    }
}
