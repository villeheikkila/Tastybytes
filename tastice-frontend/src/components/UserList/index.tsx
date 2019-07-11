import React, { useState } from "react";
import { ALL_USERS } from "./queries";
import { useQuery, useMutation } from "@apollo/react-hooks";
import { DELETE_USER, UPDATE_USER } from "../Profile/queries";
import MaterialTable from "material-table";

export const UserList = () => {
  const usersQuery = useQuery(ALL_USERS);
  const users = usersQuery.data.users;

  const handleError = (error: any) => {
    console.log("error: ", error);
  };

  const [deleteUser] = useMutation(DELETE_USER, {
    onError: handleError,
    refetchQueries: [{ query: ALL_USERS }]
  });

  const [updateUser] = useMutation(UPDATE_USER, {
    onError: handleError,
    refetchQueries: [{ query: ALL_USERS }]
  });

  if (usersQuery.data.users === undefined) {
    return null;
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
      columns={[
        { title: "First Name", field: "firstName" },
        { title: "Last Name", field: "lastName" },
        { title: "Email", field: "email" },
        { title: "ID", field: "id" }
      ]}
      data={users}
      editable={{
        onRowUpdate: (updatedUser, oldUser) =>
          new Promise(resolve => {
            setTimeout(() => {
              resolve();
              handleUpdateUser(updatedUser);
            }, 600);
          }),
        onRowDelete: oldUser =>
          new Promise(resolve => {
            setTimeout(() => {
              resolve();
              handleDeleteUser(oldUser.id);
            }, 100);
          })
      }}
    />
  );
};
