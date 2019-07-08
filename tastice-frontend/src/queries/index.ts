import { gql } from 'apollo-boost'

export const ALL_USERS = gql`
{
  users  {
    name
    id
    email
  }
}
`

export const ALL_PRODUCTS = gql`
{
  products  {
    name
    producer
    type
    id
  }
}
`

export const LOGIN = gql`
  mutation login($email: String!, $password: String!) {
    login(email: $email, password: $password)  {
        token
        user {
            email
            name
            id
        }
    }
  }
`