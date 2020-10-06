import * as Types from "../../types";

import { gql } from "@apollo/client";
import * as Apollo from "@apollo/client";
export type ReviewsQueryVariables = Types.Exact<{ [key: string]: never }>;

export type ReviewsQuery = {
  reviews: Array<
    Pick<Types.Review, "id" | "review" | "score"> & {
      treat: Pick<Types.Treat, "name"> & {
        category: Pick<Types.Category, "name">;
        subcategory: Pick<Types.Subcategory, "name">;
        company: Pick<Types.Company, "name">;
      };
    }
  >;
};

export const ReviewsDocument = gql`
  query Reviews {
    reviews(offset: 0) {
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

/**
 * __useReviewsQuery__
 *
 * To run a query within a React component, call `useReviewsQuery` and pass it any options that fit your needs.
 * When your component renders, `useReviewsQuery` returns an object from Apollo Client that contains loading, error, and data properties
 * you can use to render your UI.
 *
 * @param baseOptions options that will be passed into the query, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options;
 *
 * @example
 * const { data, loading, error } = useReviewsQuery({
 *   variables: {
 *   },
 * });
 */
export function useReviewsQuery(
  baseOptions?: Apollo.QueryHookOptions<ReviewsQuery, ReviewsQueryVariables>
) {
  return Apollo.useQuery<ReviewsQuery, ReviewsQueryVariables>(
    ReviewsDocument,
    baseOptions
  );
}
export function useReviewsLazyQuery(
  baseOptions?: Apollo.LazyQueryHookOptions<ReviewsQuery, ReviewsQueryVariables>
) {
  return Apollo.useLazyQuery<ReviewsQuery, ReviewsQueryVariables>(
    ReviewsDocument,
    baseOptions
  );
}
export type ReviewsQueryHookResult = ReturnType<typeof useReviewsQuery>;
export type ReviewsLazyQueryHookResult = ReturnType<typeof useReviewsLazyQuery>;
export type ReviewsQueryResult = Apollo.QueryResult<
  ReviewsQuery,
  ReviewsQueryVariables
>;
