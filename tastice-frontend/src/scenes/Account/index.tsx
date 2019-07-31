import { useMutation, useQuery } from '@apollo/react-hooks';
import { Avatar, Button, createStyles, Grid, makeStyles, Paper, Theme, Typography } from '@material-ui/core';
import React, { useEffect, useState } from 'react';
import { TextValidator, ValidatorForm } from 'react-material-ui-form-validator';
import useReactRouter from 'use-react-router';
import { ConfirmationDialog } from '../../components/ConfirmationDialog';
import { client } from '../../index';
import { DELETE_USER, ME, UPDATE_USER } from '../../queries';
import { errorHandler, notificationHandler } from '../../utils';

const useStyles = makeStyles((theme: Theme) =>
    createStyles({
        paper: {
            marginTop: 30,
            maxWidth: 700,
            padding: theme.spacing(3, 2),
            margin: `${theme.spacing(1)}px auto`,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            alignContent: 'center',
        },
        Avatar: {
            marginLeft: 30,
            marginRight: 30,
            marginTop: 15,
            marginBottom: 15,
            width: 150,
            height: 150,
        },
        container: {
            display: 'flex',
            flexWrap: 'wrap',
            flexDirection: 'column',
        },
        textField: {
            marginTop: 10,
        },
        button: {
            marginTop: 30,
        },
        form: { padding: theme.spacing(3, 0) },
    }),
);

export const Account = ({ setToken }: Token): JSX.Element | null => {
    const me = useQuery(ME);
    const [firstName, setFirstName] = useState('');
    const [lastName, setLastName] = useState('');
    const [email, setEmail] = useState('');
    const { history } = useReactRouter();
    const [visible, setVisible] = useState(false);

    useEffect(() => {
        if (me.data.me !== undefined && firstName === '') {
            setFirstName(me.data.me.firstName);
            setLastName(me.data.me.lastName);
            setEmail(me.data.me.email);
        }
    }, [me, firstName, lastName, email]);

    const [deleteUser] = useMutation(DELETE_USER, {
        onError: errorHandler,
    });
    const [updateUser] = useMutation(UPDATE_USER, {
        onError: errorHandler,
    });
    const classes = useStyles();

    if (me.data.me === undefined) {
        return null;
    }

    const user = me.data.me;

    const handleUpdateUser = async (): Promise<void> => {
        const result = await updateUser({
            variables: {
                id: user.id,
                firstName: firstName || user.firstName,
                lastName: lastName || user.lastName,
                email: email || user.email,
            },
        });

        if (result) {
            notificationHandler({
                message: `User '${result.data.updateUser.firstName}' succesfully updated`,
                variant: 'success',
            });
        }
    };

    const handleDeleteUser = async (): Promise<void> => {
        setVisible(false);
        await deleteUser({
            variables: { id: user.id },
        });
        await client.clearStore();
        localStorage.clear();
        setToken(null);
        history.push('/');
    };

    const handleEmailChange = (event: React.ChangeEvent<HTMLInputElement>): void => setEmail(event.target.value);

    const handleLastNameChange = (event: React.ChangeEvent<HTMLInputElement>): void => setLastName(event.target.value);

    const handleFirstNameChange = (event: React.ChangeEvent<HTMLInputElement>): void =>
        setFirstName(event.target.value);

    return (
        <div>
            <Paper className={classes.paper}>
                <Typography variant="h4" component="h3" className={classes.textField}>
                    Account Settings
                </Typography>
                <Avatar
                    alt="Avatar"
                    src="https://pixel.nymag.com/imgs/daily/vulture/2018/11/02/02-avatar-2.w700.h467.jpg"
                    className={classes.Avatar}
                />

                <ValidatorForm onSubmit={handleUpdateUser} className={classes.form} onError={errorHandler}>
                    <Grid container spacing={2}>
                        <Grid item xs={12}>
                            <TextValidator
                                autoComplete="fname"
                                name="firstName"
                                variant="outlined"
                                required
                                fullWidth
                                id="firstName"
                                label="First Name"
                                autoFocus
                                validators={[]}
                                errorMessages={[]}
                                value={firstName}
                                onChange={handleFirstNameChange}
                            />
                        </Grid>
                        <Grid item xs={12}>
                            <TextValidator
                                variant="outlined"
                                required
                                fullWidth
                                id="lastName"
                                label="Last Name"
                                name="lastName"
                                autoComplete="lname"
                                validators={[]}
                                errorMessages={[]}
                                value={lastName}
                                onChange={handleLastNameChange}
                            />
                        </Grid>

                        <Grid item xs={12}>
                            <TextValidator
                                variant="outlined"
                                required
                                fullWidth
                                id="email"
                                label="Email Address"
                                name="email"
                                autoComplete="email"
                                validators={['isEmail']}
                                errorMessages={['The entered email is not valid']}
                                value={email}
                                onChange={handleEmailChange}
                            />
                        </Grid>

                        <Button
                            type="submit"
                            variant="outlined"
                            color="primary"
                            className={classes.button}
                            onClick={handleUpdateUser}
                        >
                            Save changes
                        </Button>
                        <Button
                            variant="outlined"
                            color="secondary"
                            className={classes.button}
                            onClick={(): void => setVisible(true)}
                        >
                            Delete User
                        </Button>
                        <ConfirmationDialog
                            visible={visible}
                            setVisible={setVisible}
                            description={'hei'}
                            title={'Warning!'}
                            content={'Are you sure you want to remove your account?'}
                            onAccept={handleDeleteUser}
                            declineButton={'Cancel'}
                            acceptButton={'Yes'}
                        />
                    </Grid>
                </ValidatorForm>
            </Paper>
        </div>
    );
};
