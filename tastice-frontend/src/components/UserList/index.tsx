import * as React from "react";
import { User } from "../User";
import { IUser } from "../../types";
import { ALL_USERS } from "./queries";
import { useQuery } from "@apollo/react-hooks";

export const UserList = () => {
  const usersQuery = useQuery(ALL_USERS);
  const users = usersQuery.data.users;

  if (usersQuery.data.users === undefined) {
    return null;
  }
  return (
    <>
      <ul key="list">
        {users.map((user: IUser) => (
          <li key={user.id}>
            <User
              key={user.firstName}
              firstName={user.firstName}
              lastName={user.lastName}
              email={user.email}
              id={user.id}
            />
          </li>
        ))}
      </ul>
    </>
  );
};
