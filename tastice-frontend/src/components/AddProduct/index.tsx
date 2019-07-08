import React, { useState } from "react";
import { ADD_PRODUCT } from './queries'
import { useMutation } from '@apollo/react-hooks'

export const AddProduct = () => {
    const [name, setName] = useState('')
    const [producer, setProducer] = useState('')
    const [type, setType] = useState('')

    const handleError = (error: any) => {
        console.log('error: ', error);
    }

    const [addProduct] = useMutation(ADD_PRODUCT, {
        onError: handleError
    })


    const handleAddProduct = async (event: React.FormEvent<HTMLFormElement>
    ): Promise<void> => {

        event.preventDefault()

        const result = await addProduct({
            variables: { name, producer, type }
        })

        if (result) {
            console.log('result: ', result);
        }

        setName("")
        setProducer("")
        setType("")
    }

    return (
        <div>
            <form onSubmit={handleAddProduct}>
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