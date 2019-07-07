import * as React from "react";
import { User } from '../User'
import { IUserList } from '../../types'
import { IUser } from '../../types'

export const UserList: React.FC<IUserList> = ({ users }) => {
    return (
        <>
            <ul key="list">
                {users.map((user: IUser) =>
                    <li key={user.id}><User key={user.name} name={user.name} email={user.email} id={user.id} /></li>
                )}
            </ul>
        </>
    )
}
