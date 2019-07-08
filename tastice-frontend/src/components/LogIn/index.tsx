import React, { useState } from "react";
import { ILogIn } from '../../types'
import { Link } from "react-router-dom";

export const LogIn: React.FC<ILogIn> = ({ login, setToken }) => {
    const [email, setEmail] = useState('')
    const [password, setPassword] = useState('')

    const submit = async (event: React.FormEvent<HTMLFormElement>
    ): Promise<void> => {
        event.preventDefault()

        const result = await login({
            variables: { email, password }
        })

        if (result) {
            const token = result.data.login.token
            setToken(token)
            localStorage.setItem('token', token)
        }

        console.log('result: ', result);

        setEmail("")
        setPassword("")
    }

    return (
        <div>
            <form onSubmit={submit}>
                <div>
                    <p>Email</p>
                    <input
                        value={email}
                        onChange={({ target }) => setEmail(target.value)}
                    />
                </div>
                <div>
                    <p>Password</p>
                    <input
                        value={password}
                        onChange={({ target }) => setPassword(target.value)}
                    />
                </div>
                <button type='submit'>Log In!</button>
                <Link to="/signup" >Sign up!</Link>
            </form>
        </div>
    )
}