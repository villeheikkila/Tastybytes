/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

// ====================================================
// GraphQL mutation operation: CreateReview
// ====================================================

export interface CreateReview_createReview {
  __typename: "Review";
  id: string;
}

export interface CreateReview {
  createReview: CreateReview_createReview;
}

export interface CreateReviewVariables {
  treatId: number;
  score: number;
  review: string;
}
