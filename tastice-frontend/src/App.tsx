import * as React from "react";
import { BrowserRouter as Router, Route, Link } from "react-router-dom";

import { UserList } from './components/UserList'
import { ProductList } from './components/ProductList'
import { useQuery } from '@apollo/react-hooks'
import { gql } from 'apollo-boost'
import { AddProduct } from './components/AddProduct'
import { Index } from './components/Index'
import { Navbar } from './components/Navbar'

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
            <Router>
                <Navbar />
                <Route exact path="/" render={() => <Index />} />
                <Route exact path="/products" render={() => <ProductList products={productsQuery.data.products} />} />
                <Route exact path="/users" render={() => <UserList users={usersQuery.data.users} />} />
                <Route exact path="/addproduct" render={() => <AddProduct />} />
            </Router>
        </div>
    )
}

export default App