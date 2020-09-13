/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: Categories
// ====================================================

export interface Categories_categories_subcategories {
  __typename: "Subcategory";
  id: string;
  name: string;
}

export interface Categories_categories {
  __typename: "Category";
  id: string;
  name: string;
  subcategories: Categories_categories_subcategories[];
}

export interface Categories {
  categories: Categories_categories[];
}
