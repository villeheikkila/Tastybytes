import { gql } from "@apollo/client";

export const CURRENT_ACCOUNT = gql`
  query CurrentAccount {
    currentAccount {
      username
      email
    }
  }
`;

export const LOG_OUT = gql`
  query LogOut {
    logOut
  }
`;
