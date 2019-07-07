import * as React from "react";
import * as ReactDOM from "react-dom";
import { ApolloClient, InMemoryCache, HttpLink } from 'apollo-boost'
import { ApolloProvider } from "@apollo/react-hooks"

import App from './App'

const client = new ApolloClient({
    link: new HttpLink({
        uri: 'http://localhost:4000/'
    }),
    cache: new InMemoryCache(),
})


ReactDOM.render(
    <ApolloProvider client={client} >
        <App />,
    </ApolloProvider>,
    document.getElementById("root")
);

