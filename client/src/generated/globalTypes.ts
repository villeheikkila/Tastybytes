/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

//==============================================================
// START Enums and Input Objects
//==============================================================

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
