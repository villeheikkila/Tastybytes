import { GraphQLClient } from "graphql-request";
import { getSdk } from "~/generated/client.generated";

const client = new GraphQLClient("http://localhost:3333/graphql");

export const sdk = () => {
    return getSdk(client); 
}