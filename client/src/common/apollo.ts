import {
  ApolloClient,
  InMemoryCache,
  NormalizedCacheObject,
  split,
} from "@apollo/client";
import { getMainDefinition } from "@apollo/client/utilities";
import { WebSocketLink } from "@apollo/client/link/ws";
import { createUploadLink } from "apollo-upload-client";
import { config } from "./config";

const httpUri = !config.isLocal
  ? `https://${window.location.hostname}/graphql`
  : `http://${window.location.hostname}:4000/graphql`;

const wsURI = !config.isLocal
  ? `wss://${window.location.hostname}/subscriptions`
  : `ws://${window.location.hostname}:4000/subscriptions`;

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
