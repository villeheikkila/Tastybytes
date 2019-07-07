import * as React from "react";
import User from './components/User'
import Product from "./components/Product"
import { useApolloClient, useQuery } from '@apollo/react-hooks'
import { gql } from 'apollo-boost'
import { string } from "prop-types"
import { IUser } from './types'
import { IProduct } from './types'
import { useEffect } from "react";
import { initializeUsers } from './store/users/userAction'

const ALL_USERS = gql`
{
  users  {
    name
    id
    email
  }
}
`

const ALL_PRODUCTS = gql`
{
  products  {
    name
    producer
    type
    id
  }
}
`

const App = () => {
    const usersQuery = useQuery(ALL_USERS)
    console.log('usersQuery: ', usersQuery);
    const productsQuery = useQuery(ALL_PRODUCTS)
    console.log('productsQuery: ', productsQuery);

    useEffect(() => {
        initializeUsers()
    }, [])


    if (usersQuery.data.users !== undefined) {
        usersQuery.data.users.forEach((user: { name: string; email: string; id: string }) => console.log("hei", user.name, user.email, user.id))
    }

    if (productsQuery.data.products !== undefined) {
        productsQuery.data.products.forEach((product: { name: string; producer: string; id: string }) => console.log("hei", product.name, product.producer, product.id))
    }

    if (usersQuery.data.users === undefined || productsQuery.data.products === undefined) {
        return (
            <div><p>Loading...</p></div>
        )
    }

    return (
        <div>
            <ul key="list">
                {usersQuery.data.users.map((user: IUser) =>
                    <li key={user.id}><User key={user.name} name={user.name} email={user.email} id={user.id} /></li>
                )}
                {productsQuery.data.products.map((product: IProduct) =>
                    <li key={product.id}><Product key={product.name} name={product.name} producer={product.producer} type={product.type} id={product.id} /></li>
                )}
            </ul>
        </div>
    )
}

export default App