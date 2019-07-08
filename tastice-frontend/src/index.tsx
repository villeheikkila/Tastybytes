import React from 'react'
import * as ReactDOM from "react-dom";
import { ApolloClient, InMemoryCache, HttpLink } from 'apollo-boost'
import { ApolloProvider } from "@apollo/react-hooks"
import { createHttpLink } from 'apollo-link-http'
import { setContext } from 'apollo-link-context'
import App from './App'

// const client = new ApolloClient({
//     link: new HttpLink({
//         uri: 'http://localhost:4000/'
//     }),
//     cache: new InMemoryCache(),
// })

const httpLink = createHttpLink({
    uri: 'http://localhost:4000',
})

const authLink = setContext((_, { headers }) => {
    const token = localStorage.getItem('token')
    return {
        headers: {
            ...headers,
            authorization: token ? `Bearer ${token}` : null,
        }
    }
})

const client = new ApolloClient({
    link: authLink.concat(httpLink),
    cache: new InMemoryCache()
})

const render = () => {
    ReactDOM.render(
        <ApolloProvider client={client} >
            <App />
        </ApolloProvider>,
        document.getElementById("root")
    )
}

render()

