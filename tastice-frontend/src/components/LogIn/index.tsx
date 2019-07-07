import React, { useState } from "react";

export const LogIn = () => {
    const [email, setEmail] = useState('')
    const [password, setPassword] = useState('')

    const submit = async (event: React.FormEvent<HTMLFormElement>
    ): Promise<void> => {

        event.preventDefault()

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
                <button type='submit'>Add product!</button>
            </form>
        </div>
    )
}