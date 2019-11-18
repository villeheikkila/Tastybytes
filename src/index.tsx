import { ApolloProvider } from '@apollo/react-hooks';
import { ApolloClient, InMemoryCache, NormalizedCacheObject } from 'apollo-boost';
import { persistCache } from 'apollo-cache-persist';
import { PersistedData, PersistentStorage } from 'apollo-cache-persist/types';
import { split } from 'apollo-link';
import { setContext } from 'apollo-link-context';
import { createHttpLink } from 'apollo-link-http';
import { WebSocketLink } from 'apollo-link-ws';
import { getMainDefinition } from 'apollo-utilities';
import React from 'react';
import ReactDOM from 'react-dom';
import { App } from './App';
import { parseToken } from './utils';

const SERVER_URL: string = process.env.REACT_APP_SERVER_URL || 'localhost:4000/';
export const CLOUDINARY_UPLOAD_PRESET = process.env.REACT_APP_CLOUDINARY_UPLOAD_PRESET || 'demo';
export const CLOUDINARY_CLOUD_NAME = process.env.REACT_APP_CLOUDINARY_CLOUD_NAME;

const httpLink = createHttpLink({
    uri: `http://${SERVER_URL}`,
});

const wsLink = new WebSocketLink({
    uri: `ws://${SERVER_URL}`,
    options: { reconnect: true },
});

const cache = new InMemoryCache();

export const persistor = persistCache({
    cache,
    storage: window.localStorage as PersistentStorage<PersistedData<NormalizedCacheObject>>,
});

const authLink = setContext((_, { headers }) => {
    const token = parseToken(localStorage.getItem('user'));
    return {
        headers: {
            ...headers,
            authorization: token ? `Bearer ${token}` : null,
        },
    };
});

const link = split(
    ({ query }): boolean => {
        const { kind, operation } = getMainDefinition(query);
        return kind === 'OperationDefinition' && operation === 'subscription';
    },
    wsLink,
    authLink.concat(httpLink),
);

export const client = new ApolloClient({
    link,
    cache,
    resolvers: {},
});

const render = (): void => {
    ReactDOM.render(
        <ApolloProvider client={client}>
            <App />
        </ApolloProvider>,
        document.getElementById('root'),
    );
};

render();
