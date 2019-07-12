import { gql } from "apollo-boost";

export const NOTIFICATION = gql`
  {
    notification @client
  }
`;
