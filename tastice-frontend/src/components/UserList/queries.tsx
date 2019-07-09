import { gql } from "apollo-boost";

export const ALL_USERS = gql`
  {
    users {
      name
      id
      email
    }
  }
`;
