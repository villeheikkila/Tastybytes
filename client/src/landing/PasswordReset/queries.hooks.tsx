import * as Types from "../../types";

import { gql } from "@apollo/client";
import * as Apollo from "@apollo/client";
export type PasswordResetMutationVariables = Types.Exact<{
  token: Types.Scalars["String"];
  password: Types.Scalars["String"];
}>;

export type PasswordResetMutation = Pick<Types.Mutation, "resetPassword">;

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
