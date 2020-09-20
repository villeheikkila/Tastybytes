import { gql } from "@apollo/client";

export const SEARCH_TREATS = gql`
  query SearchTreats($searchTerm: String!, $offset: Float) {
    searchTreats(searchTerm: $searchTerm, offset: $offset) {
      id
      name
      company {
        name
        id
      }
      category {
        id
        name
      }
      subcategory {
        id
        name
      }
      reviews {
        score
        review
        author {
          username
        }
      }
    }
  }
`;
