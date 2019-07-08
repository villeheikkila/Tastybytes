import { gql } from 'apollo-boost'

export const ADD_PRODUCT = gql`
  mutation addProduct($name: String!, $producer: String!, $type: String!) {
    addProduct(name: $name, producer: $producer, type: $type)  {
        name
        producer
        type
        id
    }
  }
`