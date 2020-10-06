import * as Types from "../../types";

import { gql } from "@apollo/client";
import * as Apollo from "@apollo/client";
export type LogInQueryVariables = Types.Exact<{
  account: Types.LogInInput;
}>;

export type LogInQuery = Pick<Types.Query, "logIn">;

export type RequestAccountVerificationQueryVariables = Types.Exact<{
  username: Types.Scalars["String"];
}>;

export type RequestAccountVerificationQuery = Pick<
  Types.Query,
  "requestAccountVerification"
>;

export const LogInDocument = gql`
  query LogIn($account: LogInInput!) {
    logIn(account: $account)
  }
`;

/**
 * __useLogInQuery__
 *
 * To run a query within a React component, call `useLogInQuery` and pass it any options that fit your needs.
 * When your component renders, `useLogInQuery` returns an object from Apollo Client that contains loading, error, and data properties
 * you can use to render your UI.
 *
 * @param baseOptions options that will be passed into the query, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options;
 *
 * @example
 * const { data, loading, error } = useLogInQuery({
 *   variables: {
 *      account: // value for 'account'
 *   },
 * });
 */
export function useLogInQuery(
  baseOptions?: Apollo.QueryHookOptions<LogInQuery, LogInQueryVariables>
) {
  return Apollo.useQuery<LogInQuery, LogInQueryVariables>(
    LogInDocument,
    baseOptions
  );
}
export function useLogInLazyQuery(
  baseOptions?: Apollo.LazyQueryHookOptions<LogInQuery, LogInQueryVariables>
) {
  return Apollo.useLazyQuery<LogInQuery, LogInQueryVariables>(
    LogInDocument,
    baseOptions
  );
}
export type LogInQueryHookResult = ReturnType<typeof useLogInQuery>;
export type LogInLazyQueryHookResult = ReturnType<typeof useLogInLazyQuery>;
export type LogInQueryResult = Apollo.QueryResult<
  LogInQuery,
  LogInQueryVariables
>;
export function refetchLogInQuery(variables?: LogInQueryVariables) {
  return { query: LogInDocument, variables: variables };
}
export const RequestAccountVerificationDocument = gql`
  query RequestAccountVerification($username: String!) {
    requestAccountVerification(username: $username)
  }
`;

/**
 * __useRequestAccountVerificationQuery__
 *
 * To run a query within a React component, call `useRequestAccountVerificationQuery` and pass it any options that fit your needs.
 * When your component renders, `useRequestAccountVerificationQuery` returns an object from Apollo Client that contains loading, error, and data properties
 * you can use to render your UI.
 *
 * @param baseOptions options that will be passed into the query, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options;
 *
 * @example
 * const { data, loading, error } = useRequestAccountVerificationQuery({
 *   variables: {
 *      username: // value for 'username'
 *   },
 * });
 */
export function useRequestAccountVerificationQuery(
  baseOptions?: Apollo.QueryHookOptions<
    RequestAccountVerificationQuery,
    RequestAccountVerificationQueryVariables
  >
) {
  return Apollo.useQuery<
    RequestAccountVerificationQuery,
    RequestAccountVerificationQueryVariables
  >(RequestAccountVerificationDocument, baseOptions);
}
export function useRequestAccountVerificationLazyQuery(
  baseOptions?: Apollo.LazyQueryHookOptions<
    RequestAccountVerificationQuery,
    RequestAccountVerificationQueryVariables
  >
) {
  return Apollo.useLazyQuery<
    RequestAccountVerificationQuery,
    RequestAccountVerificationQueryVariables
  >(RequestAccountVerificationDocument, baseOptions);
}
export type RequestAccountVerificationQueryHookResult = ReturnType<
  typeof useRequestAccountVerificationQuery
>;
export type RequestAccountVerificationLazyQueryHookResult = ReturnType<
  typeof useRequestAccountVerificationLazyQuery
>;
export type RequestAccountVerificationQueryResult = Apollo.QueryResult<
  RequestAccountVerificationQuery,
  RequestAccountVerificationQueryVariables
>;
export function refetchRequestAccountVerificationQuery(
  variables?: RequestAccountVerificationQueryVariables
) {
  return { query: RequestAccountVerificationDocument, variables: variables };
}
