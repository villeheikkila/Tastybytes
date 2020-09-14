import React from "react";
import ReactDOM from "react-dom";
import "./index.css";
import App from "./App";
import * as serviceWorker from "./serviceWorker";
import {
  ApolloClient,
  InMemoryCache,
  NormalizedCacheObject,
  ApolloProvider,
  split,
  HttpLink,
  gql,
} from "@apollo/client";
import { getMainDefinition } from "@apollo/client/utilities";
import { WebSocketLink } from "@apollo/client/link/ws";

export const recaptchaSiteKey = process.env.REACT_APP_RECAPTCHA_SITE_KEY || "";

const httpLink = new HttpLink({
  uri: `http://${window.location.hostname}:${process.env.REACT_APP_API_PORT}/graphql`,
  credentials: "include",
});

const wsLink = new WebSocketLink({
  uri: `ws://${window.location.hostname}:${process.env.REACT_APP_API_PORT}/subscriptions`,
  options: {
    reconnect: true,
  },
});

const link = split(
  ({ query }) => {
    const definition = getMainDefinition(query);
    return (
      definition.kind === "OperationDefinition" &&
      definition.operation === "subscription"
    );
  },
  wsLink,
  httpLink
);
const typeDefs = gql`
  scalar GraphQL_CompanyName
  scalar GraphQL_TreatName
`;

const client: ApolloClient<NormalizedCacheObject> = new ApolloClient({
  cache: new InMemoryCache(),
  typeDefs,
  link,
});

ReactDOM.render(
  <React.StrictMode>
    <ApolloProvider client={client}>
      <App />
    </ApolloProvider>
  </React.StrictMode>,
  document.getElementById("root")
);

serviceWorker.unregister();
