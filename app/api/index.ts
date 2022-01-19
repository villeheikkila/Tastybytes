import { GraphQLClient } from "graphql-request";
import { getSdk } from "~/generated/client.generated";

export const sdk = () => {
    const client = new GraphQLClient("http://localhost:3333/graphql");
    return getSdk(client); 
}