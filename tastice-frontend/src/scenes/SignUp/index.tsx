import React, { useState } from 'react';
import useReactRouter from 'use-react-router';
import { useMutation } from '@apollo/react-hooks';
import { SIGN_UP } from '../../queries';
import { errorHandler } from '../../utils';
import { ValidatorForm, TextValidator } from 'react-material-ui-form-validator';
import 'typeface-leckerli-one';

import { Grid, Button, Typography, Container, makeStyles } from '@material-ui/core';

const useStyles = makeStyles(theme => ({
    paper: {
        marginTop: theme.spacing(8),
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
    },
    submit: {
        margin: theme.spacing(3, 0, 2),
    },
    signin: {
        margin: theme.spacing(0, 0, 0),
    },
    logo: {
        paddingRight: 15,
        paddingBottom: 15,
        fontFamily: 'Leckerli One',
    },
    title: {
        paddingBottom: 25,
    },
}));

export const SignUp = ({ setToken }: Token): JSX.Element => {
    const [firstName, setFirstName] = useState('');
    const [lastName, setLastName] = useState('');
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const { history } = useReactRouter();
    const classes = useStyles();

    const [signup] = useMutation(SIGN_UP, {
        onError: errorHandler,
    });

    const handleSignUp = async (event: any): Promise<void> => {
        event.preventDefault();
        const result = await signup({
            variables: { firstName, lastName, email, password },
        });
        if (result) {
            const token: string = result.data.signup.token;
            const userId: string = result.data.signup.user.id;
            setToken(token);
            localStorage.setItem('token', token);
            localStorage.setItem('userId', userId);
        }
    };

    const handlePushToLogin = (): void => history.push('/');

    const handlePasswordChange = (event: React.ChangeEvent<HTMLInputElement>): void => setPassword(event.target.value);

    const handleEmailChange = (event: React.ChangeEvent<HTMLInputElement>): void => setEmail(event.target.value);

    const handleLastNameChange = (event: React.ChangeEvent<HTMLInputElement>): void => setLastName(event.target.value);

    const handleFirstNameChange = (event: React.ChangeEvent<HTMLInputElement>): void =>
        setFirstName(event.target.value);

    return (
        <Container component="main" maxWidth="xs">
            <div className={classes.paper}>
                <Typography variant="h1" noWrap className={classes.logo}>
                    Tastice
                </Typography>

                <Typography component="h1" variant="h5" className={classes.title}>
                    Sign up
                </Typography>
                <ValidatorForm onSubmit={handleSignUp} onError={errorHandler}>
                    <Grid container spacing={2}>
                        <Grid item xs={12} sm={6}>
                            <TextValidator
                                autoComplete="fname"
                                name="firstName"
                                variant="outlined"
                                required
                                fullWidth
                                id="firstName"
                                label="First Name"
                                autoFocus
                                validators={['required', 'minStringLength: 3', 'maxStringLength: 12']}
                                errorMessages={[
                                    'This field is required',
                                    'The name is too short',
                                    'The name is too long',
                                ]}
                                value={firstName}
                                onChange={handleFirstNameChange}
                            />
                        </Grid>

                        <Grid item xs={12} sm={6}>
                            <TextValidator
                                variant="outlined"
                                required
                                fullWidth
                                id="lastName"
                                label="Last Name"
                                name="lastName"
                                autoComplete="lname"
                                validators={['required', 'minStringLength: 3', 'maxStringLength: 12']}
                                errorMessages={[
                                    'This field is required',
                                    'The name is too short',
                                    'The name is too long',
                                ]}
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
                                validators={['required', 'isEmail']}
                                errorMessages={['This field is required', 'The entered email is not valid']}
                                value={email}
                                onChange={handleEmailChange}
                            />
                        </Grid>

                        <Grid item xs={12}>
                            <TextValidator
                                variant="outlined"
                                required
                                fullWidth
                                name="password"
                                label="Password"
                                type="password"
                                id="password"
                                autoComplete="current-password"
                                validators={['required', 'minStringLength: 3', 'maxStringLength: 100']}
                                errorMessages={[
                                    'This field is required',
                                    'The entered password is too short',
                                    'The entered password is too long',
                                ]}
                                value={password}
                                onChange={handlePasswordChange}
                            />
                        </Grid>
                    </Grid>

                    <Button type="submit" fullWidth variant="contained" color="primary" className={classes.submit}>
                        Sign Up
                    </Button>

                    <Button
                        type="submit"
                        fullWidth
                        variant="contained"
                        color="secondary"
                        className={classes.signin}
                        onClick={handlePushToLogin}
                    >
                        Already have an account? Sign In!
                    </Button>
                </ValidatorForm>
            </div>
        </Container>
    );
};
