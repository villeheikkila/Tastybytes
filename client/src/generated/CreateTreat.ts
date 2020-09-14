/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL mutation operation: CreateTreat
// ====================================================

export interface CreateTreat_createTreat {
  __typename: "Treat";
  id: string;
}

export interface CreateTreat {
  createTreat: CreateTreat_createTreat;
}

export interface CreateTreatVariables {
  name: string;
  companyId: string;
  categoryId: string;
  subcategoryId: string;
}
