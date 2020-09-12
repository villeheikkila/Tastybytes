/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: GetTreat
// ====================================================

export interface GetTreat_treat_producedBy {
  __typename: "Company";
  name: string;
  id: string;
}

export interface GetTreat_treat_reviews {
  __typename: "Review";
  id: string;
  review: string;
  score: number;
}

export interface GetTreat_treat {
  __typename: "Treat";
  id: string;
  name: string;
  producedBy: GetTreat_treat_producedBy;
  reviews: GetTreat_treat_reviews[];
}

export interface GetTreat {
  treat: GetTreat_treat;
}

export interface GetTreatVariables {
  id: number;
}
