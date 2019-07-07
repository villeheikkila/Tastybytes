import { combineReducers } from 'redux'

import { userReducer } from './users/userReducer'

export const reducer = () => {
    return {
        users: userReducer
    }
}

export default () => combineReducers(reducer())