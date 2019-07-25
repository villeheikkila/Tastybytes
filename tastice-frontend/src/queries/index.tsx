import { gql } from 'apollo-boost';

export const THEME = gql`
    {
        theme @client
    }
`;

export const NOTIFICATION = gql`
    {
        notification @client
    }
`;

export const FILTER = gql`
    {
        filter @client
    }
`;

export const ALL_CHECKINS = gql`
    {
        checkins {
            id
            rating
            comment
            author {
                id
                firstName
                lastName
            }
            product {
                id
                name
                company {
                    name
                }
                category {
                    name
                }
                subCategory {
                    name
                }
            }
            createdAt
        }
    }
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

export const CREATE_CHECKIN = gql`
    mutation createCheckin($authorId: ID!, $productId: ID!, $comment: String!, $rating: Int!) {
        createCheckin(authorId: $authorId, productId: $productId, comment: $comment, rating: $rating) {
            product {
                name
            }
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

export const ALL_USERS = gql`
    {
        users {
            firstName
            lastName
            id
            email
            admin
        }
    }
`;

export const USER = gql`
    query user($id: ID!) {
        user(id: $id) {
            id
            firstName
            lastName
            checkins {
                rating
                comment
                author {
                    id
                    firstName
                    lastName
                }
                product {
                    id
                    name
                    company {
                        name
                    }
                    category {
                        name
                    }
                    subCategory {
                        name
                    }
                }
                createdAt
            }
        }
    }
`;

export const CHECKIN = gql`
    query checkin($id: ID!) {
        checkin(id: $id) {
            id
            rating
            comment
        }
    }
`;

export const SIGN_UP = gql`
    mutation signup($firstName: String!, $lastName: String!, $email: String!, $password: String!) {
        signup(firstName: $firstName, lastName: $lastName, email: $email, password: $password) {
            token
            user {
                email
                firstName
                lastName
                id
            }
        }
    }
`;

export const ME = gql`
    {
        me {
            id
            firstName
            lastName
            email
            admin
            checkins {
                rating
                comment
                author {
                    id
                    firstName
                    lastName
                }
                product {
                    id
                    name
                    company {
                        name
                    }
                    category {
                        name
                    }
                    subCategory {
                        name
                    }
                }
                createdAt
            }
        }
    }
`;

export const UPDATE_USER = gql`
    mutation updateUser($id: ID!, $firstName: String!, $lastName: String!, $email: String!) {
        updateUser(id: $id, firstName: $firstName, lastName: $lastName, email: $email) {
            id
            firstName
            lastName
            email
        }
    }
`;

export const UPDATE_CHECKIN = gql`
    mutation updateCheckin($id: ID!, $rating: Int!, $comment: String!) {
        updateCheckin(id: $id, rating: $rating, comment: $comment) {
            id
            rating
            comment
        }
    }
`;

export const DELETE_USER = gql`
    mutation deleteUser($id: ID!) {
        deleteUser(id: $id) {
            id
            firstName
            lastName
            email
        }
    }
`;

export const DELETE_CHECKIN = gql`
    mutation deleteCheckin($id: ID!) {
        deleteCheckin(id: $id) {
            id
        }
    }
`;

export const DELETE_PRODUCT = gql`
    mutation deleteProduct($id: ID!) {
        deleteProduct(id: $id) {
            name
            id
            company {
                name
            }
        }
    }
`;

export const ADD_PRODUCT = gql`
    mutation addProduct($name: String!, $company: String!, $categoryId: ID!, $subCategories: [String!]) {
        addProduct(name: $name, company: $company, categoryId: $categoryId, subCategories: $subCategories) {
            name
            company {
                name
            }
            id
            category {
                name
            }
            subCategory {
                name
            }
        }
    }
`;

export const UPDATE_PRODUCT = gql`
    mutation updateProduct($id: ID!, $name: String!, $company: String!, $categoryId: ID!, $subCategories: [String!]) {
        updateProduct(id: $id, name: $name, company: $company, categoryId: $categoryId, subCategories: $subCategories) {
            name
            id
        }
    }
`;

export const ALL_PRODUCTS = gql`
    {
        products {
            name
            company {
                name
            }
            id
            category {
                name
            }
            subCategory {
                name
            }
        }
    }
`;

export const PRODUCT = gql`
    query product($id: ID!) {
        product(id: $id) {
            id
            name
            company {
                name
            }
            category {
                name
            }
            subCategory {
                name
            }
            checkins {
                id
                rating
                comment
                author {
                    id
                    firstName
                    lastName
                }
                product {
                    id
                    name
                    company {
                        name
                    }
                    category {
                        name
                    }
                    subCategory {
                        name
                    }
                }
                createdAt
            }
        }
    }
`;

export const SEARCH_PRODUCTS = gql`
    query searchProducts($name: String!) {
        searchProducts(name: $name) {
            id
            name
            company {
                name
            }
            category {
                name
            }
            subCategory {
                name
            }
            checkins {
                id
                rating
                comment
                author {
                    id
                    firstName
                    lastName
                }
                product {
                    id
                    name
                    company {
                        name
                    }
                    category {
                        name
                    }
                    subCategory {
                        name
                    }
                }
                createdAt
            }
        }
    }
`;

export const LOGIN = gql`
    mutation login($email: String!, $password: String!) {
        login(email: $email, password: $password) {
            token
            user {
                email
                firstName
                lastName
                id
            }
        }
    }
`;

export const USER_ADDED = gql`
    subscription {
        user {
            node {
                lastName
                firstName
                email
            }
        }
    }
`;
