import * as SDK from "../generated/sdk";
import { GraphQLClient } from "graphql-request";

const client = new GraphQLClient(process.env.GRAPHQL_URL as string);

export const sdk = () => {
  return SDK.getSdk(client);
};

export default SDK;
