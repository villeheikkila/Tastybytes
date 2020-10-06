import * as Types from "../types";

import { gql } from "@apollo/client";
import * as Apollo from "@apollo/client";
export type VerifyAccountMutationVariables = Types.Exact<{
  token: Types.Scalars["String"];
}>;

export type VerifyAccountMutation = Pick<Types.Mutation, "verifyAccount">;

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

export type CreateAccountMutationVariables = Types.Exact<{
  account: Types.AccountInput;
}>;

export type CreateAccountMutation = {
  createAccount: Pick<Types.Account, "id">;
};

export type PasswordResetMutationVariables = Types.Exact<{
  token: Types.Scalars["String"];
  password: Types.Scalars["String"];
}>;

export type PasswordResetMutation = Pick<Types.Mutation, "resetPassword">;

export const VerifyAccountDocument = gql`
  mutation VerifyAccount($token: String!) {
    verifyAccount(token: $token)
  }
`;
export type VerifyAccountMutationFn = Apollo.MutationFunction<
  VerifyAccountMutation,
  VerifyAccountMutationVariables
>;

/**
 * __useVerifyAccountMutation__
 *
 * To run a mutation, you first call `useVerifyAccountMutation` within a React component and pass it any options that fit your needs.
 * When your component renders, `useVerifyAccountMutation` returns a tuple that includes:
 * - A mutate function that you can call at any time to execute the mutation
 * - An object with fields that represent the current status of the mutation's execution
 *
 * @param baseOptions options that will be passed into the mutation, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options-2;
 *
 * @example
 * const [verifyAccountMutation, { data, loading, error }] = useVerifyAccountMutation({
 *   variables: {
 *      token: // value for 'token'
 *   },
 * });
 */
export function useVerifyAccountMutation(
  baseOptions?: Apollo.MutationHookOptions<
    VerifyAccountMutation,
    VerifyAccountMutationVariables
  >
) {
  return Apollo.useMutation<
    VerifyAccountMutation,
    VerifyAccountMutationVariables
  >(VerifyAccountDocument, baseOptions);
}
export type VerifyAccountMutationHookResult = ReturnType<
  typeof useVerifyAccountMutation
>;
export type VerifyAccountMutationResult = Apollo.MutationResult<
  VerifyAccountMutation
>;
export type VerifyAccountMutationOptions = Apollo.BaseMutationOptions<
  VerifyAccountMutation,
  VerifyAccountMutationVariables
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
export const CreateAccountDocument = gql`
  mutation CreateAccount($account: AccountInput!) {
    createAccount(account: $account) {
      id
    }
  }
`;
export type CreateAccountMutationFn = Apollo.MutationFunction<
  CreateAccountMutation,
  CreateAccountMutationVariables
>;

/**
 * __useCreateAccountMutation__
 *
 * To run a mutation, you first call `useCreateAccountMutation` within a React component and pass it any options that fit your needs.
 * When your component renders, `useCreateAccountMutation` returns a tuple that includes:
 * - A mutate function that you can call at any time to execute the mutation
 * - An object with fields that represent the current status of the mutation's execution
 *
 * @param baseOptions options that will be passed into the mutation, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options-2;
 *
 * @example
 * const [createAccountMutation, { data, loading, error }] = useCreateAccountMutation({
 *   variables: {
 *      account: // value for 'account'
 *   },
 * });
 */
export function useCreateAccountMutation(
  baseOptions?: Apollo.MutationHookOptions<
    CreateAccountMutation,
    CreateAccountMutationVariables
  >
) {
  return Apollo.useMutation<
    CreateAccountMutation,
    CreateAccountMutationVariables
  >(CreateAccountDocument, baseOptions);
}
export type CreateAccountMutationHookResult = ReturnType<
  typeof useCreateAccountMutation
>;
export type CreateAccountMutationResult = Apollo.MutationResult<
  CreateAccountMutation
>;
export type CreateAccountMutationOptions = Apollo.BaseMutationOptions<
  CreateAccountMutation,
  CreateAccountMutationVariables
>;
export const PasswordResetDocument = gql`
  mutation PasswordReset($token: String!, $password: String!) {
    resetPassword(token: $token, password: $password)
  }
`;
export type PasswordResetMutationFn = Apollo.MutationFunction<
  PasswordResetMutation,
  PasswordResetMutationVariables
>;

/**
 * __usePasswordResetMutation__
 *
 * To run a mutation, you first call `usePasswordResetMutation` within a React component and pass it any options that fit your needs.
 * When your component renders, `usePasswordResetMutation` returns a tuple that includes:
 * - A mutate function that you can call at any time to execute the mutation
 * - An object with fields that represent the current status of the mutation's execution
 *
 * @param baseOptions options that will be passed into the mutation, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options-2;
 *
 * @example
 * const [passwordResetMutation, { data, loading, error }] = usePasswordResetMutation({
 *   variables: {
 *      token: // value for 'token'
 *      password: // value for 'password'
 *   },
 * });
 */
export function usePasswordResetMutation(
  baseOptions?: Apollo.MutationHookOptions<
    PasswordResetMutation,
    PasswordResetMutationVariables
  >
) {
  return Apollo.useMutation<
    PasswordResetMutation,
    PasswordResetMutationVariables
  >(PasswordResetDocument, baseOptions);
}
export type PasswordResetMutationHookResult = ReturnType<
  typeof usePasswordResetMutation
>;
export type PasswordResetMutationResult = Apollo.MutationResult<
  PasswordResetMutation
>;
export type PasswordResetMutationOptions = Apollo.BaseMutationOptions<
  PasswordResetMutation,
  PasswordResetMutationVariables
>;
