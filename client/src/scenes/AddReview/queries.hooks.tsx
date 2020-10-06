import * as Types from "../../types";

import { gql } from "@apollo/client";
import * as Apollo from "@apollo/client";
export type CreateReviewMutationVariables = Types.Exact<{
  review: Types.ReviewInput;
}>;

export type CreateReviewMutation = { createReview: Pick<Types.Review, "id"> };

export type GetTreatQueryVariables = Types.Exact<{
  id: Types.Scalars["ID"];
}>;

export type GetTreatQuery = {
  treat: Pick<Types.Treat, "id" | "name"> & {
    company: Pick<Types.Company, "name" | "id">;
    category: Pick<Types.Category, "name" | "id">;
    subcategory: Pick<Types.Subcategory, "name" | "id">;
    reviews: Array<Pick<Types.Review, "id" | "review" | "score">>;
  };
};

export const CreateReviewDocument = gql`
  mutation CreateReview($review: ReviewInput!) {
    createReview(review: $review) {
      id
    }
  }
`;
export type CreateReviewMutationFn = Apollo.MutationFunction<
  CreateReviewMutation,
  CreateReviewMutationVariables
>;

/**
 * __useCreateReviewMutation__
 *
 * To run a mutation, you first call `useCreateReviewMutation` within a React component and pass it any options that fit your needs.
 * When your component renders, `useCreateReviewMutation` returns a tuple that includes:
 * - A mutate function that you can call at any time to execute the mutation
 * - An object with fields that represent the current status of the mutation's execution
 *
 * @param baseOptions options that will be passed into the mutation, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options-2;
 *
 * @example
 * const [createReviewMutation, { data, loading, error }] = useCreateReviewMutation({
 *   variables: {
 *      review: // value for 'review'
 *   },
 * });
 */
export function useCreateReviewMutation(
  baseOptions?: Apollo.MutationHookOptions<
    CreateReviewMutation,
    CreateReviewMutationVariables
  >
) {
  return Apollo.useMutation<
    CreateReviewMutation,
    CreateReviewMutationVariables
  >(CreateReviewDocument, baseOptions);
}
export type CreateReviewMutationHookResult = ReturnType<
  typeof useCreateReviewMutation
>;
export type CreateReviewMutationResult = Apollo.MutationResult<
  CreateReviewMutation
>;
export type CreateReviewMutationOptions = Apollo.BaseMutationOptions<
  CreateReviewMutation,
  CreateReviewMutationVariables
>;
export const GetTreatDocument = gql`
  query GetTreat($id: ID!) {
    treat(id: $id) {
      id
      name
      company {
        name
        id
      }
      category {
        name
        id
      }
      subcategory {
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

/**
 * __useGetTreatQuery__
 *
 * To run a query within a React component, call `useGetTreatQuery` and pass it any options that fit your needs.
 * When your component renders, `useGetTreatQuery` returns an object from Apollo Client that contains loading, error, and data properties
 * you can use to render your UI.
 *
 * @param baseOptions options that will be passed into the query, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options;
 *
 * @example
 * const { data, loading, error } = useGetTreatQuery({
 *   variables: {
 *      id: // value for 'id'
 *   },
 * });
 */
export function useGetTreatQuery(
  baseOptions?: Apollo.QueryHookOptions<GetTreatQuery, GetTreatQueryVariables>
) {
  return Apollo.useQuery<GetTreatQuery, GetTreatQueryVariables>(
    GetTreatDocument,
    baseOptions
  );
}
export function useGetTreatLazyQuery(
  baseOptions?: Apollo.LazyQueryHookOptions<
    GetTreatQuery,
    GetTreatQueryVariables
  >
) {
  return Apollo.useLazyQuery<GetTreatQuery, GetTreatQueryVariables>(
    GetTreatDocument,
    baseOptions
  );
}
export type GetTreatQueryHookResult = ReturnType<typeof useGetTreatQuery>;
export type GetTreatLazyQueryHookResult = ReturnType<
  typeof useGetTreatLazyQuery
>;
export type GetTreatQueryResult = Apollo.QueryResult<
  GetTreatQuery,
  GetTreatQueryVariables
>;
