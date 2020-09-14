import {
  ApolloClient,
  InMemoryCache,
  NormalizedCacheObject,
  split,
  HttpLink,
} from "@apollo/client";
import { getMainDefinition } from "@apollo/client/utilities";
import { WebSocketLink } from "@apollo/client/link/ws";

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

export const client: ApolloClient<NormalizedCacheObject> = new ApolloClient({
  cache: new InMemoryCache(),
  link,
});
