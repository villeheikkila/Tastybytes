import * as React from "react";
import User from "./components/User";
import { useApolloClient, useQuery } from '@apollo/react-hooks'
import { gql } from 'apollo-boost'
import { string } from "prop-types";
import { IUser } from './components/User'

const ALL_USERS = gql`
{
  users  {
    name
    id
    email
  }
}
`

const App = () => {
    const usersQuery = useQuery(ALL_USERS)

    if (usersQuery.data.users !== undefined) {
        usersQuery.data.users.forEach((user: { name: string; email: string; }) => console.log("hei", user.name, user.email))
    }

    if (usersQuery.data.users === undefined) {
        return (
            <div><h1>moi</h1></div>
        )
    }

    return (
        usersQuery.data.users.map((user: IUser) =>
            <User name={user.name} email={user.email} />
        )
    )
}

export default App