import * as React from "react";


import { UserList } from './components/UserList'
import { ProductList } from './components/ProductList'
import { useQuery } from '@apollo/react-hooks'
import { gql } from 'apollo-boost'
import { AddProduct } from './components/AddProduct'

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
    const productsQuery = useQuery(ALL_PRODUCTS)

    if (usersQuery.data.users === undefined || productsQuery.data.products === undefined) {
        return (
            <div><p>Loading...</p></div>
        )
    }

    return (
        <div>
            <AddProduct />
            <UserList users={usersQuery.data.users} />
            <ProductList products={productsQuery.data.products} />
        </div>
    )
}

export default App