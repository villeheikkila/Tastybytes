import { gql } from 'apollo-boost';
import { CHECKIN_DETAILS, PRODUCT_DETAILS, USER_DETAILS } from './fragments';

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
            email
            colorScheme
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

export const ALL_USERS = gql`
    {
        users {
            ...UserDetails
            admin
            email
        }
    }
    ${USER_DETAILS}
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
    mutation updateUser($id: ID!, $firstName: String, $lastName: String, $email: String, $colorScheme: Int) {
        updateUser(id: $id, firstName: $firstName, lastName: $lastName, email: $email, colorScheme: $colorScheme) {
            ...UserDetails
        }
    }
    ${USER_DETAILS}
`;

export const DELETE_USER = gql`
    mutation deleteUser($id: ID!) {
        deleteUser(id: $id) {
            ...UserDetails
        }
    }
    ${USER_DETAILS}
`;

export const DELETE_FRIEND = gql`
    mutation deleteFriend($id: ID!, $friendId: ID!) {
        deleteFriend(id: $id, friendId: $friendId) {
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

export const FRIENDREQUEST_SUBSCRIPTION = gql`
    subscription friendRequestSubscription($id: ID!) {
        friendRequest(id: $id) {
            node {
                id
                sender {
                    ...UserDetails
                }
            }
        }
    }
    ${USER_DETAILS}
`;
