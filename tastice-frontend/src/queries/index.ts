import { gql } from 'apollo-boost'


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

