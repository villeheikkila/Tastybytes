import { useMutation } from '@apollo/react-hooks';
import { Button, createStyles, Grid, makeStyles, Theme } from '@material-ui/core';
import React, { useEffect, useState } from 'react';
import { TextValidator, ValidatorForm } from 'react-material-ui-form-validator';
import { ME, UPDATE_USER } from '../../queries';
import { errorHandler, notificationHandler } from '../../utils';

const useStyles = makeStyles((theme: Theme) =>
    createStyles({
        button: {
            marginTop: 15,
            width: '30%',
        },
        form: {
            padding: theme.spacing(3, 0),
        },
    }),
);

export const UserForm = ({ user }: any): JSX.Element | null => {
    const classes = useStyles();

    const [firstName, setFirstName] = useState('');
    const [lastName, setLastName] = useState('');
    const [email, setEmail] = useState('');

    const [updateUser] = useMutation(UPDATE_USER, {
        onError: errorHandler,
        refetchQueries: [{ query: ME }],
    });

    useEffect(() => {
        if (user !== undefined && firstName === '') {
            setFirstName(user.firstName);
            setLastName(user.lastName);
            setEmail(user.email);
        }
    }, [user, firstName, lastName, email]);

    const handleUpdateUser = async (event: any): Promise<void> => {
        event.preventDefault();

        const result = await updateUser({
            variables: {
                id: user.id,
                firstName,
                lastName,
                email,
            },
        });

        if (result) {
            notificationHandler({
                message: `User '${result.data.updateUser.firstName}' succesfully updated`,
                variant: 'success',
            });
        }
    };

    const handleEmailChange = (event: React.ChangeEvent<HTMLInputElement>): void => setEmail(event.target.value);

    const handleLastNameChange = (event: React.ChangeEvent<HTMLInputElement>): void => setLastName(event.target.value);

    const handleFirstNameChange = (event: React.ChangeEvent<HTMLInputElement>): void =>
        setFirstName(event.target.value);

    return (
        <ValidatorForm onSubmit={handleUpdateUser} className={classes.form} onError={errorHandler} >
            <Grid container spacing={2} alignItems="center" justify="center">
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
                    color="primary"
                    variant="contained"
                    className={classes.button}
                    onClick={handleUpdateUser}
                >
                    Save changes
                        </Button>
            </Grid>
        </ValidatorForm >
    );
};
