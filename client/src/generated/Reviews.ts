/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: Reviews
// ====================================================

export interface Reviews_reviews_treat_category {
  __typename: "Category";
  name: string;
}

export interface Reviews_reviews_treat_subcategory {
  __typename: "Subcategory";
  name: string;
}

export interface Reviews_reviews_treat_company {
  __typename: "Company";
  name: string;
}

export interface Reviews_reviews_treat {
  __typename: "Treat";
  name: string;
  category: Reviews_reviews_treat_category;
  subcategory: Reviews_reviews_treat_subcategory;
  company: Reviews_reviews_treat_company;
}

export interface Reviews_reviews {
  __typename: "Review";
  id: string;
  review: string;
  score: number;
  treat: Reviews_reviews_treat;
}

export interface Reviews {
  reviews: Reviews_reviews[];
}
