/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL query operation: SubcategoriesByCategory
// ====================================================

export interface SubcategoriesByCategory_subcategoriesByCategory {
  __typename: "Subcategory";
  id: string;
  name: string;
}

export interface SubcategoriesByCategory {
  subcategoriesByCategory: SubcategoriesByCategory_subcategoriesByCategory[];
}

export interface SubcategoriesByCategoryVariables {
  categoryId: string;
}
