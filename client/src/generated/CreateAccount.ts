/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

import { AccountInput } from "./globalTypes";

// ====================================================
// GraphQL mutation operation: CreateAccount
// ====================================================

export interface CreateAccount_createAccount {
  __typename: "Account";
  id: string;
}

export interface CreateAccount {
  createAccount: CreateAccount_createAccount;
}

export interface CreateAccountVariables {
  account: AccountInput;
}
