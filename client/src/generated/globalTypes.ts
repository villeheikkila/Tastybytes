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
  captchaToken: string;
  email: string;
  firstName?: string | null;
  lastName?: string | null;
  password: string;
  username: string;
}

export interface LogInInput {
  password: string;
  username: string;
}

export interface ReviewInput {
  review?: string | null;
  score: number;
  treatId: string;
}

//==============================================================
// END Enums and Input Objects
//==============================================================
