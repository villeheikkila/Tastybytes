import { gql } from "@apollo/client";

export const CREATE_TREAT = gql`
  mutation CreateTreat(
    $name: String!
    $companyId: ID!
    $categoryId: ID!
    $subcategoryId: ID!
  ) {
    createTreat(
      name: $name
      companyId: $companyId
      categoryId: $categoryId
      subcategoryId: $subcategoryId
    ) {
      id
    }
  }
`;
