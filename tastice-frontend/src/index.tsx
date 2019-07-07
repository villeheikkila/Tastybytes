import * as React from "react";
import * as ReactDOM from "react-dom";
import { ApolloClient, InMemoryCache, HttpLink } from 'apollo-boost'
import { ApolloProvider } from "@apollo/react-hooks"
import reducer from './store/rootReducer'
import { createStore, combineReducers, applyMiddleware } from 'redux'
import thunk from 'redux-thunk';
import { Provider } from 'react-redux'
import { initializeUsers } from './store/users/userAction'

import App from './App'

const client = new ApolloClient({
    link: new HttpLink({
        uri: 'http://localhost:4000/'
    }),
    cache: new InMemoryCache(),
})

const store = createStore(reducer, applyMiddleware(thunk))

const render = () => {
    ReactDOM.render(
        <ApolloProvider client={client} >
            <Provider store={store}>
                <App />
            </Provider>
        </ApolloProvider>,
        document.getElementById("root")
    )
}

render()
initializeUsers()
store.subscribe(() => {
    const storeNow = store.getState()
    console.log("state:", storeNow)
})
