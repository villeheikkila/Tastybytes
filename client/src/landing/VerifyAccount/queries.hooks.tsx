import * as Types from "../../types";

import { gql } from "@apollo/client";
import * as Apollo from "@apollo/client";
export type VerifyAccountMutationVariables = Types.Exact<{
  token: Types.Scalars["String"];
}>;

export type VerifyAccountMutation = Pick<Types.Mutation, "verifyAccount">;

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
