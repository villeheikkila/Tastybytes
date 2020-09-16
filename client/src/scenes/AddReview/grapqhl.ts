import { gql } from "@apollo/client";

export const CREATE_REVIEW = gql`
  mutation CreateReview($review: ReviewInput!) {
    createReview(review: $review) {
      id
    }
  }
`;

export const GET_TREAT = gql`
  query GetTreat($id: ID!) {
    treat(id: $id) {
      id
      name
      company {
        name
        id
      }
      reviews {
        id
        review
        score
      }
    }
  }
`;
