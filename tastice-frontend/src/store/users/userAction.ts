import { useQuery } from '@apollo/react-hooks'
import { gql } from 'apollo-boost'
import { Dispatch } from 'redux';
import { IUser, UserActionTypes } from './types'

const ALL_USERS = gql`
{
  users  {
    name
    id
    email
  }
}
`

export const initializeUsers = () => {
    console.log("TÄÄLLÄ")
    return async (dispatch: Dispatch<UserActionTypes>): Promise<void> => {
        const { data, error, loading } = useQuery(ALL_USERS)

        if (loading) {
            console.log("Loading")
        };
        if (error) {
            console.log("Error", error.message)
        };
        if (data) {
            console.log("Error", error.message)
        };

        console.log('QYERYY: ', data.users);
        dispatch({
            type: 'INITIALIZE_USERS',
            payload: data.users,
        })
    }
}