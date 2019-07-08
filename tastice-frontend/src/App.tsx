import React, { useState, useEffect } from "react";
import { BrowserRouter as Router, Route, Link } from "react-router-dom";

import { UserList } from './components/UserList'
import { ProductList } from './components/ProductList'
import { useQuery, useMutation } from '@apollo/react-hooks'
import { gql } from 'apollo-boost'
import { AddProduct } from './components/AddProduct'
import { Index } from './components/Index'
import { LogIn } from './components/LogIn'
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

const LOGIN = gql`
  mutation login($email: String!, $password: String!) {
    login(email: $email, password: $password)  {
        token
        user {
            email
            name
            id
        }
    }
  }
`

const App = () => {
    const [token, setToken] = useState(null)
    const usersQuery = useQuery(ALL_USERS)
    const productsQuery = useQuery(ALL_PRODUCTS)

    useEffect(() => {
        const token: any = localStorage.getItem('token')
        if (token) {
            setToken(token)
        }
    })

    const handleError = (error: any) => {
        console.log('error: ', error);
    }
    const [login] = useMutation(LOGIN, {
        onError: handleError
    })

    const logout = async (event: React.FormEvent<HTMLFormElement>
    ): Promise<void> => {
        event.preventDefault()
        setToken(null)
        localStorage.clear()
    }

    if (!token) {
        return (
            <LogIn login={login} setToken={setToken} />
        )
    }

    if (usersQuery.data.users === undefined || productsQuery.data.products === undefined) {
        return (
            <div><p>Loading...</p></div>
        )
    }


    return (
        <div>
            <Router>
                <Navbar logout={logout} />
                <Route exact path="/" render={() => <Index />} />
                <Route exact path="/products" render={() => <ProductList products={productsQuery.data.products} />} />
                <Route exact path="/users" render={() => <UserList users={usersQuery.data.users} />} />
                <Route exact path="/addproduct" render={() => <AddProduct />} />
            </Router>
        </div>
    )
}

export default App