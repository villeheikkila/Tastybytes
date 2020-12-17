import * as Types from "../../types";

import { gql } from "@apollo/client";
import * as Apollo from "@apollo/client";
export type CreateAccountMutationVariables = Types.Exact<{
  account: Types.AccountInput;
}>;

export type CreateAccountMutation = {
  createAccount: Pick<Types.Account, "id">;
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
