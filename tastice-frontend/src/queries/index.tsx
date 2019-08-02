import { gql } from 'apollo-boost';

const USER_DETAILS = gql`
  fragment UserDetails on User {
    id
    firstName
    lastName
    avatarId
  }
`

const PRODUCT_DETAILS = gql`
  fragment ProductDetails on Product {
    id
    name
    company {
        id
        name
    }
    category {
        id
        name
    }
    subCategory {
        id
        name
    }
  }
`

const CHECKIN_DETAILS = gql`
  fragment CheckInDetails on Checkin {
        id
        rating
        comment
        createdAt
  }
`

export const SEARCH_CHECKINS = gql`
    query searchCheckins($filter: String!) {
        searchCheckins(filter: $filter) {
            ...CheckInDetails
            author {
                ...UserDetails
            }
            product {
                ...ProductDetails
            }
        }
    }
    ${USER_DETAILS}, ${PRODUCT_DETAILS}, ${CHECKIN_DETAILS}  
`;

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

export const SEARCH_USERS = gql`
    query searchUsers($filter: String!) {
        searchUsers(filter: $filter) {
            ...UserDetails
        }
    }
    ${USER_DETAILS}
`;

export const USER = gql`
    query user($id: ID!) {
        user(id: $id) {
            ...UserDetails
            friends {
                ...UserDetails
            }
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

export const ME = gql`
    {
        me {
            ...UserDetails
            admin
            friends {
                ...UserDetails
            }
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

export const THEME = gql`
    {
        theme @client
    }
`;

export const FILTER = gql`
    {
        filter @client
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

export const CREATE_FRIENDREQUEST = gql`
    mutation createFriendRequest($senderId: ID!, $receiverId: ID!, $message: String!) {
        createFriendRequest(senderId: $senderId, receiverId: $receiverId, message: $message) {
            receiver {
                ...UserDetails
            }
            sender {
                ...UserDetails
            }
        }
    }
    ${USER_DETAILS}
`;

export const ADD_FRIEND = gql`
    mutation addFriend($id: ID!, $friendId: ID!) {
        addFriend(id: $id, friendId: $friendId) {
            friends {
                ...UserDetails
            }
        }
    }
    ${USER_DETAILS}
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
            ...UserDetails
            admin
        }
    }
    ${USER_DETAILS}
`;

export const CHECKIN = gql`
    query checkin($id: ID!) {
        checkin(id: $id) {
            ...CheckInDetails
        }
    }
    ${CHECKIN_DETAILS}
`;

export const FRIENDREQUEST = gql`
    query friendRequest($id: ID!) {
        friendRequest(id: $id) {
            id
            sender {
                ...UserDetails
            }
            receiver {
                ...UserDetails
            }
        }
    }
    ${USER_DETAILS}
`;

export const ACCEPT_FRIENDREQUEST = gql`
    mutation acceptFriendRequest($id: ID!) {
        acceptFriendRequest(id: $id) {
            id
            friends {
                ...UserDetails
            }
        }
    }
    ${USER_DETAILS}
`;

export const SIGN_UP = gql`
    mutation signup($firstName: String!, $lastName: String!, $email: String!, $password: String!) {
        signup(firstName: $firstName, lastName: $lastName, email: $email, password: $password) {
            token
            user {
                ...UserDetails
            }
        }
    }
    ${USER_DETAILS}
`;

export const UPDATE_USER = gql`
    mutation updateUser($id: ID!, $firstName: String!, $lastName: String!, $email: String!) {
        updateUser(id: $id, firstName: $firstName, lastName: $lastName, email: $email) {
            ...UserDetails
        }
    }
    ${USER_DETAILS}
`;

export const UPDATE_CHECKIN = gql`
    mutation updateCheckin($id: ID!, $rating: Int!, $comment: String!) {
        updateCheckin(id: $id, rating: $rating, comment: $comment) {
            ...CheckInDetails
        }
    }
    ${CHECKIN_DETAILS}
`;

export const DELETE_USER = gql`
    mutation deleteUser($id: ID!) {
        deleteUser(id: $id) {
            ...UserDetails
        }
    }
    ${USER_DETAILS}
`;

export const DELETE_CHECKIN = gql`
    mutation deleteCheckin($id: ID!) {
        deleteCheckin(id: $id) {
            id
        }
    }
`;

export const DELETE_FRIEND = gql`
    mutation deleteFriend($id: ID!, $friendId: ID!) {
        deleteFriend(id: $id, friendId: $friendId) {
            id
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

export const DELETE_FRIENDREQUEST = gql`
    mutation deleteFriendRequest($id: ID!) {
        deleteFriendRequest(id: $id) {
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

export const LOGIN = gql`
    mutation login($email: String!, $password: String!) {
        login(email: $email, password: $password) {
            token
            user {
                ...UserDetails
            }
        }
    }
    ${USER_DETAILS}
`;

export const USER_ADDED = gql`
    subscription {
        user {
            node {
                ...UserDetails
            }
        }
    }
    ${USER_DETAILS}
`;

export const UPDATE_PASSWORD = gql`
    mutation updateUserPassword($id: ID!, $password: String!, $existingPassword: String!) {
        updateUserPassword(id: $id, password: $password, existingPassword: $existingPassword) {
            ...UserDetails
        }
    }
    ${USER_DETAILS}
`;

export const UPDATE_AVATAR = gql`
    mutation updateUserAvatar($id: ID!, $avatarId: String!) {
        updateUserAvatar(id: $id, avatarId: $avatarId) {
            avatarId
        }
    }
`;

export const GET_NOTIFICATION = gql`
    {
        notification @client
        variant @client
    }
`;