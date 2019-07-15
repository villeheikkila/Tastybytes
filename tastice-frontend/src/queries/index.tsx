import { gql } from "apollo-boost";

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

export const ADD_PRODUCT = gql`
  mutation addProduct($name: String!, $producer: String!, $type: String!) {
    addProduct(name: $name, producer: $producer, type: $type) {
      name
      producer
      type
      id
    }
  }
`;

export const CREATE_CHECKIN = gql`
  mutation createCheckin(
    $authorId: ID!
    $productId: ID!
    $comment: String!
    $rating: Int!
  ) {
    createCheckin(
      authorId: $authorId
      productId: $productId
      comment: $comment
      rating: $rating
    ) {
      product {
        name
      }
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

export const SIGN_UP = gql`
  mutation signup(
    $firstName: String!
    $lastName: String!
    $email: String!
    $password: String!
  ) {
    signup(
      firstName: $firstName
      lastName: $lastName
      email: $email
      password: $password
    ) {
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
    }
  }
`;

export const UPDATE_USER = gql`
  mutation updateUser(
    $id: ID!
    $firstName: String!
    $lastName: String!
    $email: String!
  ) {
    updateUser(
      id: $id
      firstName: $firstName
      lastName: $lastName
      email: $email
    ) {
      id
      firstName
      lastName
      email
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

export const DELETE_PRODUCT = gql`
  mutation deleteProduct($id: ID!) {
    deleteProduct(id: $id) {
      name
      id
      producer
      type
    }
  }
`;

export const UPDATE_PRODUCT = gql`
  mutation updateProduct(
    $id: ID!
    $name: String!
    $producer: String!
    $type: String!
  ) {
    updateProduct(id: $id, name: $name, producer: $producer, type: $type) {
      name
      producer
      type
      id
    }
  }
`;

export const ALL_PRODUCTS = gql`
  {
    products {
      name
      producer
      type
      id
    }
  }
`;

export const PRODUCT = gql`
  query product($id: ID!) {
    product(id: $id) {
      name
      producer
      type
      id
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
