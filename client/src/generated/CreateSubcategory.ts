/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL mutation operation: CreateSubcategory
// ====================================================

export interface CreateSubcategory_createSubcategory {
  __typename: "Subcategory";
  id: string;
}

export interface CreateSubcategory {
  createSubcategory: CreateSubcategory_createSubcategory;
}

export interface CreateSubcategoryVariables {
  name: string;
  categoryId: string;
}
