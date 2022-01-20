import { getSdk } from "../generated/client";
import { GraphQLClient } from "graphql-request";

const client = new GraphQLClient("http://localhost:3333/graphql");

export const sdk = () => {
    return getSdk(client); 
}