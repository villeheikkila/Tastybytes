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

export const CREATE_SUBCATEGORY = gql`
  mutation CreateSubcategory($name: String!, $categoryId: ID!) {
    createSubcategory(name: $name, categoryId: $categoryId) {
      id
    }
  }
`;

export const SUBCATEGORIES = gql`
  query SubcategoriesByCategory($categoryId: ID!) {
    subcategoriesByCategory(categoryId: $categoryId) {
      id
      name
    }
  }
`;

export const QUERY_COMPANIES = gql`
  query Companies {
    companies {
      id
      name
    }
  }
`;

export const CREATE_CATEGORY = gql`
  mutation CreateCategory($name: String!) {
    createCategory(name: $name) {
      id
    }
  }
`;

export const CREATE_COMPANY = gql`
  mutation CreateCompany($name: String!) {
    createCompany(name: $name) {
      id
    }
  }
`;

export const CATEGORIES = gql`
  query Categories {
    categories {
      id
      name
      subcategories {
        id
        name
      }
    }
  }
`;
