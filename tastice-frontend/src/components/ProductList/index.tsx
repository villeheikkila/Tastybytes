import * as React from "react";
import { Product } from '../Product'
import { IProductList } from '../../types'
import { IProduct } from '../../types'

export const ProductList: React.FC<IProductList> = ({ products }) => {
    return (
        <>
            <ul key="list">
                {products.map((product: IProduct) =>
                    <li key={product.id}><Product key={product.name} name={product.name} producer={product.producer} type={product.type} id={product.id} /></li>
                )}
            </ul>
        </>
    )
}