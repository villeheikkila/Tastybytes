import {
  ApolloClient,
  InMemoryCache,
  NormalizedCacheObject,
  split,
} from "@apollo/client";
import { getMainDefinition } from "@apollo/client/utilities";
import { WebSocketLink } from "@apollo/client/link/ws";
import { createUploadLink } from "apollo-upload-client";

const httpLink = createUploadLink({
  uri: `http://${window.location.hostname}:4000/graphql`,
  credentials: "include",
});

const wsLink = new WebSocketLink({
  uri: `ws://${window.location.hostname}:4000/subscriptions`,
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
