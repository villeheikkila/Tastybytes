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