import {
  ApolloClient,
  InMemoryCache,
  NormalizedCacheObject,
  split,
} from "@apollo/client";
import { getMainDefinition } from "@apollo/client/utilities";
import { WebSocketLink } from "@apollo/client/link/ws";
import { createUploadLink } from "apollo-upload-client";

const httpUri =
  process.env.NODE_ENV === "development"
    ? `http://${window.location.hostname}:4000/graphql`
    : `https://${window.location.hostname}/graphql`;

const wsURI =
  process.env.NODE_ENV === "development"
    ? `ws://${window.location.hostname}:4000/subscriptions`
    : `wss://${window.location.hostname}/subscriptions`;

const httpLink = createUploadLink({
  uri: httpUri,
  credentials: "include",
});

const wsLink = new WebSocketLink({
  uri: wsURI,
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
