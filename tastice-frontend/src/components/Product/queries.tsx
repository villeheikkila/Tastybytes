import { gql } from 'apollo-boost'

export const DELETE_PRODUCT = gql`
  mutation deleteProduct($id: ID!) {
    deleteProduct(id: $id)  {
        name
        id
        producer
        type
    }
  }
`

export const UPDATE_PRODUCT = gql`
    mutation updateProduct($id: ID!, $name: String!, $producer: String!, $type: String!) {
        updateProduct(id: $id, name: $name, producer: $producer, type: $type)  {
            name
            producer
            type
            id
        }
  }
`