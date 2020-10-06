import * as Types from "../../types";
import { gql } from "@apollo/client";
import * as Apollo from "@apollo/client";
export type SearchTreatsQueryVariables = Types.Exact<{
  searchTerm: Types.Scalars["String"];
  offset: Types.Scalars["Float"];
}>;

export type SearchTreatsQuery = {
  searchTreats: Array<
    Pick<Types.Treat, "id" | "name"> & {
      company: Pick<Types.Company, "name" | "id">;
      category: Pick<Types.Category, "id" | "name">;
      subcategory: Pick<Types.Subcategory, "id" | "name">;
      reviews: Array<
        Pick<Types.Review, "id" | "score" | "review"> & {
          author: Pick<Types.Account, "username">;
        }
      >;
    }
  >;
};

export const SearchTreatsDocument = gql`
  query SearchTreats($searchTerm: String!, $offset: Float!) {
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
        id
        score
        review
        author {
          username
        }
      }
    }
  }
`;

/**
 * __useSearchTreatsQuery__
 *
 * To run a query within a React component, call `useSearchTreatsQuery` and pass it any options that fit your needs.
 * When your component renders, `useSearchTreatsQuery` returns an object from Apollo Client that contains loading, error, and data properties
 * you can use to render your UI.
 *
 * @param baseOptions options that will be passed into the query, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options;
 *
 * @example
 * const { data, loading, error } = useSearchTreatsQuery({
 *   variables: {
 *      searchTerm: // value for 'searchTerm'
 *      offset: // value for 'offset'
 *   },
 * });
 */
export function useSearchTreatsQuery(
  baseOptions?: Apollo.QueryHookOptions<
    SearchTreatsQuery,
    SearchTreatsQueryVariables
  >
) {
  return Apollo.useQuery<SearchTreatsQuery, SearchTreatsQueryVariables>(
    SearchTreatsDocument,
    baseOptions
  );
}
export function useSearchTreatsLazyQuery(
  baseOptions?: Apollo.LazyQueryHookOptions<
    SearchTreatsQuery,
    SearchTreatsQueryVariables
  >
) {
  return Apollo.useLazyQuery<SearchTreatsQuery, SearchTreatsQueryVariables>(
    SearchTreatsDocument,
    baseOptions
  );
}
export type SearchTreatsQueryHookResult = ReturnType<
  typeof useSearchTreatsQuery
>;
export type SearchTreatsLazyQueryHookResult = ReturnType<
  typeof useSearchTreatsLazyQuery
>;
export type SearchTreatsQueryResult = Apollo.QueryResult<
  SearchTreatsQuery,
  SearchTreatsQueryVariables
>;
