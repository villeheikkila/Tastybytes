import { gql } from 'apollo-boost';
import { CHECKIN_DETAILS, PRODUCT_DETAILS, USER_DETAILS } from './fragments';

export const SEARCH_CHECKINS = gql`
    query searchCheckins($filter: String, $first: Int, $skip: Int) {
        searchCheckins(filter: $filter, first: $first, skip: $skip) {
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

export const CREATE_CHECKIN = gql`
    mutation createCheckin($authorId: ID!, $image: String, $productId: ID!, $comment: String, $rating: Int!) {
        createCheckin(authorId: $authorId, image: $image, productId: $productId, comment: $comment, rating: $rating) {
            product {
                name
            }
        }
    }
`;

export const CHECKIN = gql`
    query checkin($id: ID!) {
        checkin(id: $id) {
            ...CheckInDetails
        }
    }
    ${CHECKIN_DETAILS}
`;

export const UPDATE_CHECKIN = gql`
    mutation updateCheckin($id: ID!, $rating: Int!, $comment: String!) {
        updateCheckin(id: $id, rating: $rating, comment: $comment) {
            ...CheckInDetails
        }
    }
    ${CHECKIN_DETAILS}
`;

export const DELETE_CHECKIN = gql`
    mutation deleteCheckin($id: ID!) {
        deleteCheckin(id: $id) {
            id
        }
    }
`;
