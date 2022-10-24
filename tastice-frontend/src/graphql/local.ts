import { gql } from 'apollo-boost';

export const GET_NOTIFICATION = gql`
    {
        notification @client
        variant @client
    }
`;

export const FILTER = gql`
    {
        filter @client
    }
`;
