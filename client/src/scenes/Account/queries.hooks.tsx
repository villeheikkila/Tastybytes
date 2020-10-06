import * as Types from "../../types";

import { gql } from "@apollo/client";
import * as Apollo from "@apollo/client";
export type CurrentAccountQueryVariables = Types.Exact<{
  [key: string]: never;
}>;

export type CurrentAccountQuery = {
  currentAccount: Pick<Types.Account, "username" | "email" | "avatarUri">;
};

export type LogOutQueryVariables = Types.Exact<{ [key: string]: never }>;

export type LogOutQuery = Pick<Types.Query, "logOut">;

export type UploadProfilePictureMutationVariables = Types.Exact<{
  picture: Types.Scalars["Upload"];
}>;

export type UploadProfilePictureMutation = {
  uploadProfilePicture: Pick<Types.Image, "filename" | "avatarUri">;
};

export const CurrentAccountDocument = gql`
  query CurrentAccount {
    currentAccount {
      username
      email
      avatarUri
    }
  }
`;

/**
 * __useCurrentAccountQuery__
 *
 * To run a query within a React component, call `useCurrentAccountQuery` and pass it any options that fit your needs.
 * When your component renders, `useCurrentAccountQuery` returns an object from Apollo Client that contains loading, error, and data properties
 * you can use to render your UI.
 *
 * @param baseOptions options that will be passed into the query, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options;
 *
 * @example
 * const { data, loading, error } = useCurrentAccountQuery({
 *   variables: {
 *   },
 * });
 */
export function useCurrentAccountQuery(
  baseOptions?: Apollo.QueryHookOptions<
    CurrentAccountQuery,
    CurrentAccountQueryVariables
  >
) {
  return Apollo.useQuery<CurrentAccountQuery, CurrentAccountQueryVariables>(
    CurrentAccountDocument,
    baseOptions
  );
}
export function useCurrentAccountLazyQuery(
  baseOptions?: Apollo.LazyQueryHookOptions<
    CurrentAccountQuery,
    CurrentAccountQueryVariables
  >
) {
  return Apollo.useLazyQuery<CurrentAccountQuery, CurrentAccountQueryVariables>(
    CurrentAccountDocument,
    baseOptions
  );
}
export type CurrentAccountQueryHookResult = ReturnType<
  typeof useCurrentAccountQuery
>;
export type CurrentAccountLazyQueryHookResult = ReturnType<
  typeof useCurrentAccountLazyQuery
>;
export type CurrentAccountQueryResult = Apollo.QueryResult<
  CurrentAccountQuery,
  CurrentAccountQueryVariables
>;
export function refetchCurrentAccountQuery(
  variables?: CurrentAccountQueryVariables
) {
  return { query: CurrentAccountDocument, variables: variables };
}
export const LogOutDocument = gql`
  query LogOut {
    logOut
  }
`;

/**
 * __useLogOutQuery__
 *
 * To run a query within a React component, call `useLogOutQuery` and pass it any options that fit your needs.
 * When your component renders, `useLogOutQuery` returns an object from Apollo Client that contains loading, error, and data properties
 * you can use to render your UI.
 *
 * @param baseOptions options that will be passed into the query, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options;
 *
 * @example
 * const { data, loading, error } = useLogOutQuery({
 *   variables: {
 *   },
 * });
 */
export function useLogOutQuery(
  baseOptions?: Apollo.QueryHookOptions<LogOutQuery, LogOutQueryVariables>
) {
  return Apollo.useQuery<LogOutQuery, LogOutQueryVariables>(
    LogOutDocument,
    baseOptions
  );
}
export function useLogOutLazyQuery(
  baseOptions?: Apollo.LazyQueryHookOptions<LogOutQuery, LogOutQueryVariables>
) {
  return Apollo.useLazyQuery<LogOutQuery, LogOutQueryVariables>(
    LogOutDocument,
    baseOptions
  );
}
export type LogOutQueryHookResult = ReturnType<typeof useLogOutQuery>;
export type LogOutLazyQueryHookResult = ReturnType<typeof useLogOutLazyQuery>;
export type LogOutQueryResult = Apollo.QueryResult<
  LogOutQuery,
  LogOutQueryVariables
>;
export function refetchLogOutQuery(variables?: LogOutQueryVariables) {
  return { query: LogOutDocument, variables: variables };
}
export const UploadProfilePictureDocument = gql`
  mutation UploadProfilePicture($picture: Upload!) {
    uploadProfilePicture(picture: $picture) {
      filename
      avatarUri
    }
  }
`;
export type UploadProfilePictureMutationFn = Apollo.MutationFunction<
  UploadProfilePictureMutation,
  UploadProfilePictureMutationVariables
>;

/**
 * __useUploadProfilePictureMutation__
 *
 * To run a mutation, you first call `useUploadProfilePictureMutation` within a React component and pass it any options that fit your needs.
 * When your component renders, `useUploadProfilePictureMutation` returns a tuple that includes:
 * - A mutate function that you can call at any time to execute the mutation
 * - An object with fields that represent the current status of the mutation's execution
 *
 * @param baseOptions options that will be passed into the mutation, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options-2;
 *
 * @example
 * const [uploadProfilePictureMutation, { data, loading, error }] = useUploadProfilePictureMutation({
 *   variables: {
 *      picture: // value for 'picture'
 *   },
 * });
 */
export function useUploadProfilePictureMutation(
  baseOptions?: Apollo.MutationHookOptions<
    UploadProfilePictureMutation,
    UploadProfilePictureMutationVariables
  >
) {
  return Apollo.useMutation<
    UploadProfilePictureMutation,
    UploadProfilePictureMutationVariables
  >(UploadProfilePictureDocument, baseOptions);
}
export type UploadProfilePictureMutationHookResult = ReturnType<
  typeof useUploadProfilePictureMutation
>;
export type UploadProfilePictureMutationResult = Apollo.MutationResult<
  UploadProfilePictureMutation
>;
export type UploadProfilePictureMutationOptions = Apollo.BaseMutationOptions<
  UploadProfilePictureMutation,
  UploadProfilePictureMutationVariables
>;
