import * as React from "react";
import { IProduct } from '../../types'

export const Product: React.FC<IProduct> = ({ name, producer, type, id }) => {
    return (
        <div>
            <p>name: {name} producer: {producer} type: {type} </p>
        </div>
    )
}