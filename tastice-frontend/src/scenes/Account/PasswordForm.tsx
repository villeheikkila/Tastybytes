import { useApolloClient, useMutation } from '@apollo/react-hooks';
import { Button, createStyles, makeStyles, TextField, Typography } from '@material-ui/core';
import React, { useState } from 'react';
import { UPDATE_PASSWORD } from '../../graphql';

const useStyles = makeStyles(() =>
    createStyles({
        textField: {
            marginTop: 10,
        },
        button: {
            marginTop: 15,
            width: '30%',
        },
    }),
);

export const PasswordForm = ({ id }: any): JSX.Element => {
    const classes = useStyles();
    const client = useApolloClient();

    const [currentPassword, setCurrentPassword] = useState('');
    const [newPassword, setNewPassword] = useState('');
    const [newPasswordCheck, setNewPasswordCheck] = useState('');

    const [changePassword] = useMutation(UPDATE_PASSWORD, {
        onError: error => {
            client.writeData({
                data: {
                    notification: error.message,
                    variant: 'error',
                },
            });
        },
    });

    const handlePasswordChange = async (): Promise<void> => {
        if (newPassword.length < 3) {
            client.writeData({
                data: {
                    notification: `The password can't be under three characters`,
                    variant: 'error',
                },
            });
        } else if (newPassword !== newPasswordCheck) {
            client.writeData({
                data: {
                    notification: `The given passwords don't match`,
                    variant: 'error',
                },
            });
            setNewPassword('');
            setNewPasswordCheck('');
        } else {
            const result = await changePassword({
                variables: {
                    id,
                    existingPassword: currentPassword,
                    password: newPassword,
                },
            });

            if (result) {
                client.writeData({
                    data: {
                        notification: `Password succesfully updated!`,
                        variant: 'success',
                    },
                });
                setCurrentPassword('');
                setNewPassword('');
                setNewPasswordCheck('');
            }
        }
    };

    return (
        <>
            <Typography variant="h5" component="h5" className={classes.textField}>
                Change Password
            </Typography>

            <TextField
                variant="outlined"
                margin="normal"
                required
                fullWidth
                name="password"
                label="Current Password"
                type="password"
                autoComplete="current-password"
                value={currentPassword}
                onChange={({ target }): void => setCurrentPassword(target.value)}
            />
            <TextField
                variant="outlined"
                margin="normal"
                required
                fullWidth
                name="newPassword"
                label="New Password"
                type="password"
                value={newPassword}
                onChange={({ target }): void => setNewPassword(target.value)}
            />
            <TextField
                variant="outlined"
                margin="normal"
                required
                fullWidth
                name="newPasswordCheck"
                label="Repeat New Password"
                type="password"
                value={newPasswordCheck}
                onChange={({ target }): void => setNewPasswordCheck(target.value)}
            />

            <Button onClick={handlePasswordChange} variant="contained" color="primary" className={classes.button}>
                Change password!
            </Button>
        </>
    );
};
