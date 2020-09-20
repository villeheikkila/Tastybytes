/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

//==============================================================
// START Enums and Input Objects
//==============================================================

/**
 * Return values for the login query.
 */
export enum LoginResult {
  INCORRECT_PASSWORD = "INCORRECT_PASSWORD",
  INEXISTENT_ACCOUNT = "INEXISTENT_ACCOUNT",
  SUCCESS = "SUCCESS",
  UNVERIFIED_ACCOUNT = "UNVERIFIED_ACCOUNT",
}

export interface AccountInput {
  username: string;
  email: string;
  password: string;
  captchaToken: string;
  firstName?: string | null;
  lastName?: string | null;
}

export interface LogInInput {
  username: string;
  password: string;
}

export interface ReviewInput {
  treatId: string;
  score: number;
  review?: string | null;
}

//==============================================================
// END Enums and Input Objects
//==============================================================
