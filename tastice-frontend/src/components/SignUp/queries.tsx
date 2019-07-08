import { gql } from 'apollo-boost'

export const SIGN_UP = gql`
  mutation signup($name: String!, $email: String!, $password: String!) {
    signup(name: $name, email: $email, password: $password)  {
        token
        user {
            email
            name
            id
        }
    }
  }
`