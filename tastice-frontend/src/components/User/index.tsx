import * as React from "react";
import { IUser } from '../../types'

export const User: React.FC<IUser> = ({ name, email, id }) => {
    return (
        <div>
            <p>name: {name} email: {email} id: {id} </p>
        </div>
    )
}
