/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: SearchTreats
// ====================================================

export interface SearchTreats_searchTreats_producedBy {
  __typename: "Company";
  name: string;
  id: string;
}

export interface SearchTreats_searchTreats_reviews_author {
  __typename: "Account";
  firstName: string;
  lastName: string;
}

export interface SearchTreats_searchTreats_reviews {
  __typename: "Review";
  score: number;
  review: string;
  author: SearchTreats_searchTreats_reviews_author;
}

export interface SearchTreats_searchTreats {
  __typename: "Treat";
  id: string;
  name: string;
  producedBy: SearchTreats_searchTreats_producedBy;
  reviews: SearchTreats_searchTreats_reviews[];
}

export interface SearchTreats {
  searchTreats: SearchTreats_searchTreats[];
}

export interface SearchTreatsVariables {
  searchTerm: string;
}
