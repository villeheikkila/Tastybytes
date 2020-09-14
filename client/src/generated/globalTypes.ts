/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

//==============================================================
// START Enums and Input Objects
//==============================================================

export interface AccountInput {
  username: GraphQL_UserName;
  email: GraphQL_Email;
  password: GraphQL_Password;
  captchaToken: string;
  firstName?: string | null;
  lastName?: string | null;
}

export interface LogInInput {
  username: GraphQL_UserName;
  password: GraphQL_Password;
}

export interface ReviewInput {
  treatId: string;
  score: number;
  review?: GraphQL_ReviewText | null;
}

//==============================================================
// END Enums and Input Objects
//==============================================================
