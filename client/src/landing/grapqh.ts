import { gql } from "@apollo/client";

export const VERIFY_EMAIL = gql`
  mutation ChangePassword($token: String!) {
    verifyAccount(token: $token)
  }
`;

export const LOGIN = gql`
  query LogIn($account: LogInInput!) {
    logIn(account: $account)
  }
`;

export const REQUEST_VERIFICATION = gql`
  query RequestAccountVerification($username: String!) {
    requestAccountVerification(username: $username)
  }
`;

export const CREATE_ACCOUNT = gql`
  mutation CreateAccount($account: AccountInput!) {
    createAccount(account: $account) {
      id
    }
  }
`;

export const PASSWORD_RESET = gql`
  mutation PasswordResetMutation($token: String!, $password: String!) {
    resetPassword(token: $token, password: $password)
  }
`;
