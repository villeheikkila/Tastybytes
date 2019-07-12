import { gql } from "apollo-boost";

export const THEME = gql`
  {
    theme @client
  }
`;
