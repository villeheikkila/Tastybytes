import React from "react";
import * as ReactDOM from "react-dom";
import { ApolloClient, InMemoryCache, HttpLink } from "apollo-boost";
import { ApolloProvider } from "@apollo/react-hooks";
import { createHttpLink } from "apollo-link-http";
import { setContext } from "apollo-link-context";
import { split } from "apollo-link";
import { WebSocketLink } from "apollo-link-ws";
import { getMainDefinition } from "apollo-utilities";
import App from "./App";

const SERVER_URL: string =
  process.env.REACT_APP_SERVER_URL || "http://localhost:4000/";

const httpLink = createHttpLink({
  uri: `http://${SERVER_URL}`
});

const wsLink = new WebSocketLink({
  uri: `ws://${SERVER_URL}`,
  options: { reconnect: true }
});

const authLink = setContext((_, { headers }) => {
  const token = localStorage.getItem("token");
  return {
    headers: {
      ...headers,
      authorization: token ? `Bearer ${token}` : null
    }
  };
});

const link = split(
  ({ query }) => {
    const { kind, operation } = getMainDefinition(query);
    return kind === "OperationDefinition" && operation === "subscription";
  },
  wsLink,
  authLink.concat(httpLink)
);

export const client = new ApolloClient({
  link,
  cache: new InMemoryCache()
});

// Default theme to dark
client.writeData({
  data: {
    theme: false
  }
});

const render = () => {
  ReactDOM.render(
    <ApolloProvider client={client}>
      <App />
    </ApolloProvider>,
    document.getElementById("root")
  );
};

render();
