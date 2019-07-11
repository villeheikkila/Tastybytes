import React, { useState } from "react";
import { ALL_USERS } from "./queries";
import { useQuery, useMutation } from "@apollo/react-hooks";
import { DELETE_USER, UPDATE_USER } from "../Profile/queries";
import { IUser } from "../../types";
import MaterialTable from "material-table";

export const UserList = () => {
  const usersQuery = useQuery(ALL_USERS);
  const users = usersQuery.data.users;
  const array: IUser[] = [];
  const [state, setState] = useState({
    columns: [
      { title: "First Name", field: "firstName" },
      { title: "Last Name", field: "lastName" },
      { title: "Email", field: "email" },
      { title: "ID", field: "id" }
    ],
    data: array
  });

  const handleError = (error: any) => {
    console.log("error: ", error);
  };

  const [deleteUser] = useMutation(DELETE_USER, {
    onError: handleError
  });

  const [updateUser] = useMutation(UPDATE_USER, {
    onError: handleError
  });

  if (usersQuery.data.users === undefined) {
    return null;
  }

  if (state.data.length === 0) {
    users.forEach((element: any) => {
      state.data.push(element);
    });
  }

  const handleDeleteUser = async (id: any) => {
    const result = await deleteUser({
      variables: { id }
    });
    if (result) {
      console.log("result: ", result);
    }
  };

  const handleUpdateUser = async (user: any) => {
    const result = await updateUser({
      variables: {
        id: user.id,
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email
      }
    });

    if (result) {
      console.log("result: ", result);
    }
  };

  return (
    <MaterialTable
      title="Registered Users"
      columns={state.columns}
      data={state.data}
      editable={{
        onRowUpdate: (updatedUser, oldUser) =>
          new Promise(resolve => {
            setTimeout(() => {
              resolve();
              handleUpdateUser(updatedUser);
              const data = [...state.data];
              data[data.indexOf(oldUser)] = updatedUser;
              setState({ ...state, data });
            }, 600);
          }),
        onRowDelete: oldUser =>
          new Promise(resolve => {
            setTimeout(() => {
              resolve();
              handleDeleteUser(oldUser.id);
              const data = [...state.data];
              data.splice(data.indexOf(oldUser), 1);
              setState({ ...state, data });
            }, 100);
          })
      }}
    />
  );
};
