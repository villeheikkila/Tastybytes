import * as React from "react";
import { Product } from '../Product'
import { IProductList } from '../../types'
import { IProduct } from '../../types'
import { Link } from 'react-router-dom'

export const ProductList: React.FC<IProductList> = ({ products }) => {
    return (
        <>
            <ul key="list">
                {products.map((product: IProduct) =>
                    <li key={product.id}> <Link to={`/products/${product.id}`}>{product.name}</Link></li>
                )}
            </ul>
        </>
    )
}

{/* <ul key="list">
{products.map((product: IProduct) =>
    <li key={product.id}><Product key={product.name} product={product} /></li>
)}
</ul> */}