import React, { useState } from "react";

export const AddProduct = () => {
    const [name, setName] = useState('')
    const [producer, setProducer] = useState('')
    const [type, setType] = useState('')

    const submit = async (event: React.FormEvent<HTMLFormElement>
    ): Promise<void> => {

        event.preventDefault()

        setName("")
        setProducer("")
        setType("")
    }

    return (
        <div>
            <form onSubmit={submit}>
                <div>
                    <p>Name</p>
                    <input
                        value={name}
                        onChange={({ target }) => setName(target.value)}
                    />
                </div>
                <div>
                    <p>Producer</p>
                    <input
                        value={producer}
                        onChange={({ target }) => setProducer(target.value)}
                    />
                </div>
                <div>
                    <p>Type</p>
                    <input
                        value={type}
                        onChange={({ target }) => setType(target.value)}
                    />
                </div>
                <button type='submit'>Add product!</button>
            </form>
        </div>
    )
}