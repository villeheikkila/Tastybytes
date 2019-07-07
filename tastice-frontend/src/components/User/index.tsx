import * as React from "react";
import { IUser } from '../../types'

const User: React.FC<IUser> = ({ name, email, id }) => {
    return (
        <div>
            <p>name: {name} email: {email} id: {id} </p>
        </div>
    )
}

export default User