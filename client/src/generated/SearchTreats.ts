/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: SearchTreats
// ====================================================

export interface SearchTreats_treats_producedBy {
  __typename: "Company";
  name: string;
  id: string;
}

export interface SearchTreats_treats_reviews_author {
  __typename: "Account";
  firstName: string;
  lastName: string;
}

export interface SearchTreats_treats_reviews {
  __typename: "Review";
  score: number;
  review: string;
  author: SearchTreats_treats_reviews_author;
}

export interface SearchTreats_treats {
  __typename: "Treat";
  id: string;
  name: string;
  producedBy: SearchTreats_treats_producedBy;
  reviews: SearchTreats_treats_reviews[];
}

export interface SearchTreats {
  treats: SearchTreats_treats[];
}
