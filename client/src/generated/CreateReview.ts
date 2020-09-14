/* tslint:disable */
/* eslint-disable */
// @generated
// This file was automatically generated and should not be edited.

import { ReviewInput } from "./globalTypes";

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
  review: ReviewInput;
}
