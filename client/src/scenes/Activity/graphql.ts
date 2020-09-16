import { gql } from "@apollo/client";

export const GET_REVIEWS = gql`
  query Reviews {
    reviews {
      id
      review
      score
      treat {
        name
        category {
          name
        }
        subcategory {
          name
        }
        company {
          name
        }
      }
    }
  }
`;
