/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: SearchTreats
// ====================================================

export interface SearchTreats_searchTreats_company {
  __typename: "Company";
  name: string;
  id: string;
}

export interface SearchTreats_searchTreats_category {
  __typename: "Category";
  id: string;
  name: string;
}

export interface SearchTreats_searchTreats_subcategory {
  __typename: "Subcategory";
  id: string;
  name: string;
}

export interface SearchTreats_searchTreats_reviews_author {
  __typename: "Account";
  username: string;
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
  company: SearchTreats_searchTreats_company;
  category: SearchTreats_searchTreats_category;
  subcategory: SearchTreats_searchTreats_subcategory;
  reviews: SearchTreats_searchTreats_reviews[];
}

export interface SearchTreats {
  searchTreats: SearchTreats_searchTreats[];
}

export interface SearchTreatsVariables {
  searchTerm: string;
}
