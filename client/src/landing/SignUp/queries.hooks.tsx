import * as Types from "../../types";

import { gql } from "@apollo/client";
import * as Apollo from "@apollo/client";
export type CreateAccountMutationVariables = Types.Exact<{
  account: Types.AccountInput;
}>;

export type CreateAccountMutation = {
  createAccount: Pick<Types.Account, "id">;
};

export type RecaptchaSiteKeyQueryVariables = Types.Exact<{
  [key: string]: never;
}>;

export type RecaptchaSiteKeyQuery = {
  configs: Pick<Types.Config, "recaptchaSiteKey">;
};

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
export type CreateAccountMutationResult = Apollo.MutationResult<CreateAccountMutation>;
export type CreateAccountMutationOptions = Apollo.BaseMutationOptions<
  CreateAccountMutation,
  CreateAccountMutationVariables
>;
export const RecaptchaSiteKeyDocument = gql`
  query RecaptchaSiteKey {
    configs {
      recaptchaSiteKey
    }
  }
`;

/**
 * __useRecaptchaSiteKeyQuery__
 *
 * To run a query within a React component, call `useRecaptchaSiteKeyQuery` and pass it any options that fit your needs.
 * When your component renders, `useRecaptchaSiteKeyQuery` returns an object from Apollo Client that contains loading, error, and data properties
 * you can use to render your UI.
 *
 * @param baseOptions options that will be passed into the query, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options;
 *
 * @example
 * const { data, loading, error } = useRecaptchaSiteKeyQuery({
 *   variables: {
 *   },
 * });
 */
export function useRecaptchaSiteKeyQuery(
  baseOptions?: Apollo.QueryHookOptions<
    RecaptchaSiteKeyQuery,
    RecaptchaSiteKeyQueryVariables
  >
) {
  return Apollo.useQuery<RecaptchaSiteKeyQuery, RecaptchaSiteKeyQueryVariables>(
    RecaptchaSiteKeyDocument,
    baseOptions
  );
}
export function useRecaptchaSiteKeyLazyQuery(
  baseOptions?: Apollo.LazyQueryHookOptions<
    RecaptchaSiteKeyQuery,
    RecaptchaSiteKeyQueryVariables
  >
) {
  return Apollo.useLazyQuery<
    RecaptchaSiteKeyQuery,
    RecaptchaSiteKeyQueryVariables
  >(RecaptchaSiteKeyDocument, baseOptions);
}
export type RecaptchaSiteKeyQueryHookResult = ReturnType<
  typeof useRecaptchaSiteKeyQuery
>;
export type RecaptchaSiteKeyLazyQueryHookResult = ReturnType<
  typeof useRecaptchaSiteKeyLazyQuery
>;
export type RecaptchaSiteKeyQueryResult = Apollo.QueryResult<
  RecaptchaSiteKeyQuery,
  RecaptchaSiteKeyQueryVariables
>;
export function refetchRecaptchaSiteKeyQuery(
  variables?: RecaptchaSiteKeyQueryVariables
) {
  return { query: RecaptchaSiteKeyDocument, variables: variables };
}
