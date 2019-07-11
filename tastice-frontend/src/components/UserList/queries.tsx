import { gql } from "apollo-boost";

export const ALL_USERS = gql`
  {
    users {
      firstName
      lastName
      id
      email
    }
  }
`;
