import React, { useState } from "react";
import { SIGN_UP } from './queries'
import { useMutation } from '@apollo/react-hooks'

export const SignUp = () => {
    const [name, setName] = useState('')
    const [email, setEmail] = useState('')
    const [password, setPassword] = useState('')

    const handleError = (error: any) => {
        console.log('error: ', error);
    }

    const [signup] = useMutation(SIGN_UP, {
        onError: handleError
    })

    const handleSignUp = async (event: React.FormEvent<HTMLFormElement>
    ): Promise<void> => {
        event.preventDefault()

        const result = await signup({
            variables: { name, email, password }
        })

        console.log('result: ', result);

        if (result) {
            const token = result.data.login.token
            console.log('token: ', token);
        }

        setEmail("")
        setPassword("")
    }

    return (
        <div>
            <form onSubmit={handleSignUp}>
                <div>
                    <p>Name</p>
                    <input
                        value={name}
                        onChange={({ target }) => setName(target.value)}
                    />
                </div>
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
                <button type='submit'>Create User!</button>
            </form>
        </div>
    )
}