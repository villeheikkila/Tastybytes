import { useApolloClient, useMutation } from '@apollo/react-hooks';
import { Button, Container, makeStyles, TextField, Typography } from '@material-ui/core';
import { writeStorage } from '@rehooks/local-storage';
import React, { useState } from 'react';
import 'typeface-leckerli-one';
import useReactRouter from 'use-react-router';
import { LOGIN } from '../../graphql';

const useStyles = makeStyles(theme => ({
    paper: {
        marginTop: theme.spacing(8),
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
    },
    form: {
        marginTop: theme.spacing(1),
    },
    submit: {
        margin: theme.spacing(3, 0, 2),
    },
    signup: {
        margin: theme.spacing(0, 0, 0),
    },
    logo: {
        paddingRight: 15,
        paddingBottom: 15,
        fontFamily: 'Leckerli One',
    },
    title: {
        paddingBottom: 5,
    },
}));

export const LogIn = (): JSX.Element => {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const { history } = useReactRouter();
    const client = useApolloClient();
    const classes = useStyles({});

    const [login] = useMutation(LOGIN, {
        onError: error => {
            client.writeData({
                data: {
                    notification: error.message,
                    variant: 'error',
                },
            });
        },
    });

    const handleLogin = async (event: React.FormEvent<HTMLFormElement>): Promise<void> => {
        event.preventDefault();

        const result = await login({
            variables: { email, password },
        });

        if (result) {
            const {
                data: {
                    login: { token, user },
                },
            } = result;
            writeStorage('user', { token, id: user.id, admin: user.admin });
        }
    };

    const handlePushToSignUp = (): void => history.push('/signup');

    return (
        <Container component="main" maxWidth="xs">
            <div className={classes.paper}>
                <Typography variant="h1" noWrap className={classes.logo}>
                    Tastice
                </Typography>

                <Typography component="h1" variant="h5" className={classes.title}>
                    Sign in
                </Typography>

                <form className={classes.form} onSubmit={handleLogin} noValidate>
                    <TextField
                        variant="outlined"
                        margin="normal"
                        required
                        fullWidth
                        id="email"
                        label="Email Address"
                        name="email"
                        autoComplete="email"
                        autoFocus
                        onChange={({ target }): void => setEmail(target.value)}
                    />

                    <TextField
                        variant="outlined"
                        margin="normal"
                        required
                        fullWidth
                        name="password"
                        label="Password"
                        type="password"
                        id="password"
                        autoComplete="current-password"
                        onChange={({ target }): void => setPassword(target.value)}
                    />

                    <Button type="submit" fullWidth variant="contained" color="primary" className={classes.submit}>
                        Sign In
                    </Button>

                    <Button
                        type="submit"
                        fullWidth
                        variant="contained"
                        color="secondary"
                        className={classes.signup}
                        onClick={handlePushToSignUp}
                    >
                        {"Don't have an account? Sign Up"}
                    </Button>
                </form>
            </div>
        </Container>
    );
};
