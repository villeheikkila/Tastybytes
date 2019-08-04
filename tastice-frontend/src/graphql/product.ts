import { gql } from 'apollo-boost';
import { USER_DETAILS, PRODUCT_DETAILS, CHECKIN_DETAILS } from './fragments'

export const SEARCH_PRODUCTS = gql`
    query searchProducts($filter: String!) {
        searchProducts(filter: $filter) {
            ...ProductDetails
            checkins {
                ...CheckInDetails
                author {
                    ...UserDetails
                }
                product {
                    ...ProductDetails
                }
            }
        }
    }
    ${USER_DETAILS}, ${PRODUCT_DETAILS}, ${CHECKIN_DETAILS}  
`;

export const ALL_CATEGORIES = gql`
    {
        categories {
            name
            id
            subCategory {
                id
                name
            }
        }
    }
`;

export const ALL_COMPANIES = gql`
    {
        companies {
            name
            id
        }
    }
`;

export const CREATE_SUBCATEGORY = gql`
    mutation createSubCategory($categoryId: ID!, $name: String!) {
        createSubCategory(categoryId: $categoryId, name: $name) {
            id
            name
        }
    }
`;

export const DELETE_PRODUCT = gql`
    mutation deleteProduct($id: ID!) {
        deleteProduct(id: $id) {
            name
            id
        }
    }
`;


export const ADD_PRODUCT = gql`
    mutation addProduct($name: String!, $company: String!, $categoryId: ID!, $subCategories: [String!]) {
        addProduct(name: $name, company: $company, categoryId: $categoryId, subCategories: $subCategories) {
            ...ProductDetails
        }
    }
    ${PRODUCT_DETAILS}
`;

export const UPDATE_PRODUCT = gql`
    mutation updateProduct($id: ID!, $name: String!, $company: String!, $categoryId: ID!, $subCategories: [String!]) {
        updateProduct(id: $id, name: $name, company: $company, categoryId: $categoryId, subCategories: $subCategories) {
            ...ProductDetails
            checkins {
                ...CheckInDetails
                author {
                    ...UserDetails
                }
                product {
                    ...ProductDetails
                }
            }
        }
    }
    ${USER_DETAILS}, ${PRODUCT_DETAILS}, ${CHECKIN_DETAILS}
`;

export const ALL_PRODUCTS = gql`
    {
        products {
            ...ProductDetails
        }
    }
    ${PRODUCT_DETAILS}
`;

export const PRODUCT = gql`
    query product($id: ID!) {
        product(id: $id) {
            ...ProductDetails
            checkins {
                ...CheckInDetails
                author {
                    ...UserDetails
                }
                product {
                    ...ProductDetails
                }
            }
        }
    }
    ${USER_DETAILS}, ${PRODUCT_DETAILS}, ${CHECKIN_DETAILS}
`;
