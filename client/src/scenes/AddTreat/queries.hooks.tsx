import * as Types from "../../types";

import { gql } from "@apollo/client";
import * as Apollo from "@apollo/client";
export type CreateTreatMutationVariables = Types.Exact<{
  name: Types.Scalars["String"];
  companyId: Types.Scalars["ID"];
  categoryId: Types.Scalars["ID"];
  subcategoryId: Types.Scalars["ID"];
}>;

export type CreateTreatMutation = { createTreat: Pick<Types.Treat, "id"> };

export type CreateSubcategoryMutationVariables = Types.Exact<{
  name: Types.Scalars["String"];
  categoryId: Types.Scalars["ID"];
}>;

export type CreateSubcategoryMutation = {
  createSubcategory: Pick<Types.Subcategory, "id">;
};

export type SubcategoriesByCategoryQueryVariables = Types.Exact<{
  categoryId: Types.Scalars["ID"];
}>;

export type SubcategoriesByCategoryQuery = {
  subcategoriesByCategory: Array<Pick<Types.Subcategory, "id" | "name">>;
};

export type CompaniesQueryVariables = Types.Exact<{ [key: string]: never }>;

export type CompaniesQuery = {
  companies: Array<Pick<Types.Company, "id" | "name">>;
};

export type CreateCategoryMutationVariables = Types.Exact<{
  name: Types.Scalars["String"];
}>;

export type CreateCategoryMutation = {
  createCategory: Pick<Types.Category, "id">;
};

export type CreateCompanyMutationVariables = Types.Exact<{
  name: Types.Scalars["String"];
}>;

export type CreateCompanyMutation = {
  createCompany: Pick<Types.Company, "id">;
};

export type CategoriesQueryVariables = Types.Exact<{ [key: string]: never }>;

export type CategoriesQuery = {
  categories: Array<
    Pick<Types.Category, "id" | "name"> & {
      subcategories: Array<Pick<Types.Subcategory, "id" | "name">>;
    }
  >;
};

export const CreateTreatDocument = gql`
  mutation CreateTreat(
    $name: String!
    $companyId: ID!
    $categoryId: ID!
    $subcategoryId: ID!
  ) {
    createTreat(
      name: $name
      companyId: $companyId
      categoryId: $categoryId
      subcategoryId: $subcategoryId
    ) {
      id
    }
  }
`;
export type CreateTreatMutationFn = Apollo.MutationFunction<
  CreateTreatMutation,
  CreateTreatMutationVariables
>;

/**
 * __useCreateTreatMutation__
 *
 * To run a mutation, you first call `useCreateTreatMutation` within a React component and pass it any options that fit your needs.
 * When your component renders, `useCreateTreatMutation` returns a tuple that includes:
 * - A mutate function that you can call at any time to execute the mutation
 * - An object with fields that represent the current status of the mutation's execution
 *
 * @param baseOptions options that will be passed into the mutation, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options-2;
 *
 * @example
 * const [createTreatMutation, { data, loading, error }] = useCreateTreatMutation({
 *   variables: {
 *      name: // value for 'name'
 *      companyId: // value for 'companyId'
 *      categoryId: // value for 'categoryId'
 *      subcategoryId: // value for 'subcategoryId'
 *   },
 * });
 */
export function useCreateTreatMutation(
  baseOptions?: Apollo.MutationHookOptions<
    CreateTreatMutation,
    CreateTreatMutationVariables
  >
) {
  return Apollo.useMutation<CreateTreatMutation, CreateTreatMutationVariables>(
    CreateTreatDocument,
    baseOptions
  );
}
export type CreateTreatMutationHookResult = ReturnType<
  typeof useCreateTreatMutation
>;
export type CreateTreatMutationResult = Apollo.MutationResult<
  CreateTreatMutation
>;
export type CreateTreatMutationOptions = Apollo.BaseMutationOptions<
  CreateTreatMutation,
  CreateTreatMutationVariables
>;
export const CreateSubcategoryDocument = gql`
  mutation CreateSubcategory($name: String!, $categoryId: ID!) {
    createSubcategory(name: $name, categoryId: $categoryId) {
      id
    }
  }
`;
export type CreateSubcategoryMutationFn = Apollo.MutationFunction<
  CreateSubcategoryMutation,
  CreateSubcategoryMutationVariables
>;

/**
 * __useCreateSubcategoryMutation__
 *
 * To run a mutation, you first call `useCreateSubcategoryMutation` within a React component and pass it any options that fit your needs.
 * When your component renders, `useCreateSubcategoryMutation` returns a tuple that includes:
 * - A mutate function that you can call at any time to execute the mutation
 * - An object with fields that represent the current status of the mutation's execution
 *
 * @param baseOptions options that will be passed into the mutation, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options-2;
 *
 * @example
 * const [createSubcategoryMutation, { data, loading, error }] = useCreateSubcategoryMutation({
 *   variables: {
 *      name: // value for 'name'
 *      categoryId: // value for 'categoryId'
 *   },
 * });
 */
export function useCreateSubcategoryMutation(
  baseOptions?: Apollo.MutationHookOptions<
    CreateSubcategoryMutation,
    CreateSubcategoryMutationVariables
  >
) {
  return Apollo.useMutation<
    CreateSubcategoryMutation,
    CreateSubcategoryMutationVariables
  >(CreateSubcategoryDocument, baseOptions);
}
export type CreateSubcategoryMutationHookResult = ReturnType<
  typeof useCreateSubcategoryMutation
>;
export type CreateSubcategoryMutationResult = Apollo.MutationResult<
  CreateSubcategoryMutation
>;
export type CreateSubcategoryMutationOptions = Apollo.BaseMutationOptions<
  CreateSubcategoryMutation,
  CreateSubcategoryMutationVariables
>;
export const SubcategoriesByCategoryDocument = gql`
  query SubcategoriesByCategory($categoryId: ID!) {
    subcategoriesByCategory(categoryId: $categoryId) {
      id
      name
    }
  }
`;

/**
 * __useSubcategoriesByCategoryQuery__
 *
 * To run a query within a React component, call `useSubcategoriesByCategoryQuery` and pass it any options that fit your needs.
 * When your component renders, `useSubcategoriesByCategoryQuery` returns an object from Apollo Client that contains loading, error, and data properties
 * you can use to render your UI.
 *
 * @param baseOptions options that will be passed into the query, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options;
 *
 * @example
 * const { data, loading, error } = useSubcategoriesByCategoryQuery({
 *   variables: {
 *      categoryId: // value for 'categoryId'
 *   },
 * });
 */
export function useSubcategoriesByCategoryQuery(
  baseOptions?: Apollo.QueryHookOptions<
    SubcategoriesByCategoryQuery,
    SubcategoriesByCategoryQueryVariables
  >
) {
  return Apollo.useQuery<
    SubcategoriesByCategoryQuery,
    SubcategoriesByCategoryQueryVariables
  >(SubcategoriesByCategoryDocument, baseOptions);
}
export function useSubcategoriesByCategoryLazyQuery(
  baseOptions?: Apollo.LazyQueryHookOptions<
    SubcategoriesByCategoryQuery,
    SubcategoriesByCategoryQueryVariables
  >
) {
  return Apollo.useLazyQuery<
    SubcategoriesByCategoryQuery,
    SubcategoriesByCategoryQueryVariables
  >(SubcategoriesByCategoryDocument, baseOptions);
}
export type SubcategoriesByCategoryQueryHookResult = ReturnType<
  typeof useSubcategoriesByCategoryQuery
>;
export type SubcategoriesByCategoryLazyQueryHookResult = ReturnType<
  typeof useSubcategoriesByCategoryLazyQuery
>;
export type SubcategoriesByCategoryQueryResult = Apollo.QueryResult<
  SubcategoriesByCategoryQuery,
  SubcategoriesByCategoryQueryVariables
>;
export function refetchSubcategoriesByCategoryQuery(
  variables?: SubcategoriesByCategoryQueryVariables
) {
  return { query: SubcategoriesByCategoryDocument, variables: variables };
}
export const CompaniesDocument = gql`
  query Companies {
    companies {
      id
      name
    }
  }
`;

/**
 * __useCompaniesQuery__
 *
 * To run a query within a React component, call `useCompaniesQuery` and pass it any options that fit your needs.
 * When your component renders, `useCompaniesQuery` returns an object from Apollo Client that contains loading, error, and data properties
 * you can use to render your UI.
 *
 * @param baseOptions options that will be passed into the query, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options;
 *
 * @example
 * const { data, loading, error } = useCompaniesQuery({
 *   variables: {
 *   },
 * });
 */
export function useCompaniesQuery(
  baseOptions?: Apollo.QueryHookOptions<CompaniesQuery, CompaniesQueryVariables>
) {
  return Apollo.useQuery<CompaniesQuery, CompaniesQueryVariables>(
    CompaniesDocument,
    baseOptions
  );
}
export function useCompaniesLazyQuery(
  baseOptions?: Apollo.LazyQueryHookOptions<
    CompaniesQuery,
    CompaniesQueryVariables
  >
) {
  return Apollo.useLazyQuery<CompaniesQuery, CompaniesQueryVariables>(
    CompaniesDocument,
    baseOptions
  );
}
export type CompaniesQueryHookResult = ReturnType<typeof useCompaniesQuery>;
export type CompaniesLazyQueryHookResult = ReturnType<
  typeof useCompaniesLazyQuery
>;
export type CompaniesQueryResult = Apollo.QueryResult<
  CompaniesQuery,
  CompaniesQueryVariables
>;
export function refetchCompaniesQuery(variables?: CompaniesQueryVariables) {
  return { query: CompaniesDocument, variables: variables };
}
export const CreateCategoryDocument = gql`
  mutation CreateCategory($name: String!) {
    createCategory(name: $name) {
      id
    }
  }
`;
export type CreateCategoryMutationFn = Apollo.MutationFunction<
  CreateCategoryMutation,
  CreateCategoryMutationVariables
>;

/**
 * __useCreateCategoryMutation__
 *
 * To run a mutation, you first call `useCreateCategoryMutation` within a React component and pass it any options that fit your needs.
 * When your component renders, `useCreateCategoryMutation` returns a tuple that includes:
 * - A mutate function that you can call at any time to execute the mutation
 * - An object with fields that represent the current status of the mutation's execution
 *
 * @param baseOptions options that will be passed into the mutation, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options-2;
 *
 * @example
 * const [createCategoryMutation, { data, loading, error }] = useCreateCategoryMutation({
 *   variables: {
 *      name: // value for 'name'
 *   },
 * });
 */
export function useCreateCategoryMutation(
  baseOptions?: Apollo.MutationHookOptions<
    CreateCategoryMutation,
    CreateCategoryMutationVariables
  >
) {
  return Apollo.useMutation<
    CreateCategoryMutation,
    CreateCategoryMutationVariables
  >(CreateCategoryDocument, baseOptions);
}
export type CreateCategoryMutationHookResult = ReturnType<
  typeof useCreateCategoryMutation
>;
export type CreateCategoryMutationResult = Apollo.MutationResult<
  CreateCategoryMutation
>;
export type CreateCategoryMutationOptions = Apollo.BaseMutationOptions<
  CreateCategoryMutation,
  CreateCategoryMutationVariables
>;
export const CreateCompanyDocument = gql`
  mutation CreateCompany($name: String!) {
    createCompany(name: $name) {
      id
    }
  }
`;
export type CreateCompanyMutationFn = Apollo.MutationFunction<
  CreateCompanyMutation,
  CreateCompanyMutationVariables
>;

/**
 * __useCreateCompanyMutation__
 *
 * To run a mutation, you first call `useCreateCompanyMutation` within a React component and pass it any options that fit your needs.
 * When your component renders, `useCreateCompanyMutation` returns a tuple that includes:
 * - A mutate function that you can call at any time to execute the mutation
 * - An object with fields that represent the current status of the mutation's execution
 *
 * @param baseOptions options that will be passed into the mutation, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options-2;
 *
 * @example
 * const [createCompanyMutation, { data, loading, error }] = useCreateCompanyMutation({
 *   variables: {
 *      name: // value for 'name'
 *   },
 * });
 */
export function useCreateCompanyMutation(
  baseOptions?: Apollo.MutationHookOptions<
    CreateCompanyMutation,
    CreateCompanyMutationVariables
  >
) {
  return Apollo.useMutation<
    CreateCompanyMutation,
    CreateCompanyMutationVariables
  >(CreateCompanyDocument, baseOptions);
}
export type CreateCompanyMutationHookResult = ReturnType<
  typeof useCreateCompanyMutation
>;
export type CreateCompanyMutationResult = Apollo.MutationResult<
  CreateCompanyMutation
>;
export type CreateCompanyMutationOptions = Apollo.BaseMutationOptions<
  CreateCompanyMutation,
  CreateCompanyMutationVariables
>;
export const CategoriesDocument = gql`
  query Categories {
    categories {
      id
      name
      subcategories {
        id
        name
      }
    }
  }
`;

/**
 * __useCategoriesQuery__
 *
 * To run a query within a React component, call `useCategoriesQuery` and pass it any options that fit your needs.
 * When your component renders, `useCategoriesQuery` returns an object from Apollo Client that contains loading, error, and data properties
 * you can use to render your UI.
 *
 * @param baseOptions options that will be passed into the query, supported options are listed on: https://www.apollographql.com/docs/react/api/react-hooks/#options;
 *
 * @example
 * const { data, loading, error } = useCategoriesQuery({
 *   variables: {
 *   },
 * });
 */
export function useCategoriesQuery(
  baseOptions?: Apollo.QueryHookOptions<
    CategoriesQuery,
    CategoriesQueryVariables
  >
) {
  return Apollo.useQuery<CategoriesQuery, CategoriesQueryVariables>(
    CategoriesDocument,
    baseOptions
  );
}
export function useCategoriesLazyQuery(
  baseOptions?: Apollo.LazyQueryHookOptions<
    CategoriesQuery,
    CategoriesQueryVariables
  >
) {
  return Apollo.useLazyQuery<CategoriesQuery, CategoriesQueryVariables>(
    CategoriesDocument,
    baseOptions
  );
}
export type CategoriesQueryHookResult = ReturnType<typeof useCategoriesQuery>;
export type CategoriesLazyQueryHookResult = ReturnType<
  typeof useCategoriesLazyQuery
>;
export type CategoriesQueryResult = Apollo.QueryResult<
  CategoriesQuery,
  CategoriesQueryVariables
>;
export function refetchCategoriesQuery(variables?: CategoriesQueryVariables) {
  return { query: CategoriesDocument, variables: variables };
}
