import * as React from "react";
import { IProduct } from '../../types'
import { DELETE_PRODUCT } from './queries'
import { useMutation } from '@apollo/react-hooks'

export const Product: React.FC<IProduct> = ({ name, producer, type, id }) => {

    const handleError = (error: any) => {
        console.log('error: ', error);
    }

    const [deleteProduct] = useMutation(DELETE_PRODUCT, {
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

    return (
        <div>
            <p>name: {name} producer: {producer} type: {type} </p>
            <button onClick={handleDeleteProduct}>Delete</button>
        </div>
    )
}