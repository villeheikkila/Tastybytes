import {
  ApolloClient,
  InMemoryCache,
  NormalizedCacheObject,
  split,
} from "@apollo/client";
import { getMainDefinition } from "@apollo/client/utilities";
import { WebSocketLink } from "@apollo/client/link/ws";
import { createUploadLink } from "apollo-upload-client";
import config from "./config";

const httpLink = createUploadLink({
  uri: config.isProd
    ? `https://${window.location.hostname}/graphql`
    : `http://${window.location.hostname}:4000/graphql`,
  credentials: "include",
});

const wsLink = new WebSocketLink({
  uri: config.isProd
    ? `wss://${window.location.hostname}/subscriptions`
    : `ws://${window.location.hostname}:4000/subscriptions`,
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
