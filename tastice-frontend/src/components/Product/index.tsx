import React, { useState } from "react";
import { IProduct } from '../../types'
import { DELETE_PRODUCT, UPDATE_PRODUCT } from './queries'
import { useMutation } from '@apollo/react-hooks'

export const Product: React.FC<IProduct> = ({ name, producer, type, id }) => {
    const [updatedName, setUpdatedName] = useState('')
    const [updatedProducer, setUpdatedProducer] = useState('')
    const [updatedType, setUpdatedType] = useState('')

    const handleError = (error: any) => {
        console.log('error: ', error);
    }

    const [deleteProduct] = useMutation(DELETE_PRODUCT, {
        onError: handleError
    })

    const [updateProduct] = useMutation(UPDATE_PRODUCT, {
        onError: handleError
    })

    const handleDeleteProduct = async () => {
        console.log('id:', id, "id");

        const result = await deleteProduct({
            variables: { id }
        })

        if (result) {
            console.log('result: ', result);
        }

    }

    const handleUpdateProduct = async (event: React.FormEvent<HTMLFormElement>
    ): Promise<void> => {

        event.preventDefault()

        console.log('updatedType: ', updatedType);
        console.log('updatedProducer: ', updatedProducer);
        console.log('updatedName: ', updatedName);
        console.log('id: ', id);

        const result = await updateProduct({
            variables: { id, name: updatedName, producer: updatedProducer, type: updatedType }
        })

        if (result) {
            console.log('result: ', result);
        }

        setUpdatedName("")
        setUpdatedProducer("")
        setUpdatedType("")
    }

    return (
        <div>
            <p>name: {name} producer: {producer} type: {type} </p>
            <button onClick={handleDeleteProduct}>Delete</button>
            <form onSubmit={handleUpdateProduct}>
                <div>
                    <p>New name</p>
                    <input
                        value={updatedName}
                        onChange={({ target }) => setUpdatedName(target.value)}
                    />
                </div>
                <div>
                    <p>New producer</p>
                    <input
                        value={updatedProducer}
                        onChange={({ target }) => setUpdatedProducer(target.value)}
                    />
                </div>
                <div>
                    <p>New type</p>
                    <input
                        value={updatedType}
                        onChange={({ target }) => setUpdatedType(target.value)}
                    />
                </div>
                <button type='submit'>Update product!</button>
            </form>
        </div>
    )
}