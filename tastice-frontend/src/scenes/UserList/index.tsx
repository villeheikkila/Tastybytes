import { useMutation, useQuery } from '@apollo/react-hooks';
import MaterialTable from 'material-table';
import React from 'react';
import { ALL_USERS, DELETE_USER, UPDATE_USER } from '../../graphql';
import { errorHandler, notificationHandler } from '../../utils';

export const UserList = (): JSX.Element | null => {
    const usersQuery = useQuery(ALL_USERS);
    const users = usersQuery.data.users;

    const [deleteUser] = useMutation(DELETE_USER, {
        onError: errorHandler,
        refetchQueries: [{ query: ALL_USERS }],
    });

    const [updateUser] = useMutation(UPDATE_USER, {
        onError: errorHandler,
        refetchQueries: [{ query: ALL_USERS }],
    });

    if (usersQuery.data.users === undefined) {
        return null;
    }

    const handleDeleteUser = async (id: string): Promise<void> => {
        const result = await deleteUser({
            variables: { id },
        });
        if (result) {
            notificationHandler({
                message: `User '${result.data.deleteUser.firstName}' succesfully deleted`,
                variant: 'success',
            });
        }
    };

    const handleUpdateUser = async (user: User): Promise<void> => {
        const result = await updateUser({
            variables: {
                id: user.id,
                firstName: user.firstName,
                lastName: user.lastName,
                email: user.email,
            },
        });

        if (result) {
            notificationHandler({
                message: `User '${result.data.updateUser.firstName}' succesfully updated`,
                variant: 'success',
            });
        }
    };

    return (
        <MaterialTable
            title="Registered Users"
            columns={[
                { title: 'First Name', field: 'firstName' },
                { title: 'Last Name', field: 'lastName' },
                { title: 'Email', field: 'email' },
                { title: 'ID', field: 'id' },
            ]}
            data={users}
            editable={{
                onRowUpdate: updatedUser =>
                    new Promise(resolve => {
                        setTimeout((): void => {
                            resolve();
                            handleUpdateUser(updatedUser);
                        }, 600);
                    }),
                onRowDelete: oldUser =>
                    new Promise(resolve => {
                        setTimeout((): void => {
                            resolve();
                            handleDeleteUser(oldUser.id);
                        }, 100);
                    }),
            }}
        />
    );
};
