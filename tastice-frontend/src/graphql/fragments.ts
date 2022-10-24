import { gql } from 'apollo-boost';

export const USER_DETAILS = gql`
    fragment UserDetails on User {
        id
        firstName
        lastName
        avatarId
        avatarColor
    }
`;

export const PRODUCT_DETAILS = gql`
    fragment ProductDetails on Product {
        id
        name
        imageId
        company {
            id
            name
        }
        category {
            id
            name
            color
        }
        subCategory {
            id
            name
        }
    }
`;

export const CHECKIN_DETAILS = gql`
    fragment CheckInDetails on Checkin {
        id
        rating
        comment
        createdAt
        image
    }
`;
