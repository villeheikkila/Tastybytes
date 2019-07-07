import * as React from "react";

export interface IUser {
    name: string,
    email: string
}

const User: React.FC<IUser> = ({ name, email }) => {
    return (
        <div>
            <p>name: {name} email: {email} </p>
        </div>
    )
}

export default User