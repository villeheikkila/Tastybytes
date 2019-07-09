import React, { useState } from "react";
import { SIGN_UP } from "./queries";
import { useMutation } from "@apollo/react-hooks";
import { Link } from "react-router-dom";
import { ILogIn } from "../../types";

import Button from "@material-ui/core/Button";
import CssBaseline from "@material-ui/core/CssBaseline";
import TextField from "@material-ui/core/TextField";
import Grid from "@material-ui/core/Grid";
import Typography from "@material-ui/core/Typography";
import { makeStyles } from "@material-ui/core/styles";
import Container from "@material-ui/core/Container";

const useStyles = makeStyles(theme => ({
  "@global": {
    body: {
      backgroundColor: theme.palette.common.white
    }
  },
  paper: {
    marginTop: theme.spacing(8),
    display: "flex",
    flexDirection: "column",
    alignItems: "center"
  },
  img: {
    marginTop: theme.spacing(300)
  },
  form: {
    marginTop: theme.spacing(3)
  },
  submit: {
    margin: theme.spacing(3, 0, 2)
  },
  image: {
    marginBottom: theme.spacing(2)
  },
  signin: {
    margin: theme.spacing(0, 0, 0)
  }
}));

export const SignUp: React.FC<ILogIn> = ({ login, setToken }) => {
  const [firstName, setLastName] = useState("");
  const [lastName, setFirstName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const classes = useStyles();

  const handleError = (error: any) => {
    console.log("error: ", error);
  };

  const [signup] = useMutation(SIGN_UP, {
    onError: handleError
  });

  const handleSignUp = async (
    event: React.FormEvent<HTMLFormElement>
  ): Promise<void> => {
    event.preventDefault();

    const result = await signup({
      variables: { name: firstName, email, password }
    });

    if (result) {
      const token = result.data.signup.token;
      setToken(token);
      localStorage.setItem("token", token);
    }
  };

  return (
    <Container component="main" maxWidth="xs">
      <CssBaseline />
      <div className={classes.paper}>
        <img
          className={classes.image}
          src="https://fontmeme.com/permalink/190704/0daa2ab57e001e0aa2002608810c7a69.png"
          alt="logo"
        />

        <Typography component="h1" variant="h5">
          Sign up
        </Typography>

        <form className={classes.form} onSubmit={handleSignUp} noValidate>
          <Grid container spacing={2}>
            <Grid item xs={12} sm={6}>
              <TextField
                autoComplete="fname"
                name="firstName"
                variant="outlined"
                required
                fullWidth
                id="firstName"
                label="First Name"
                autoFocus
                onChange={({ target }) => setFirstName(target.value)}
              />
            </Grid>

            <Grid item xs={12} sm={6}>
              <TextField
                variant="outlined"
                required
                fullWidth
                id="lastName"
                label="Last Name"
                name="lastName"
                autoComplete="lname"
                onChange={({ target }) => setLastName(target.value)}
              />
            </Grid>

            <Grid item xs={12}>
              <TextField
                variant="outlined"
                required
                fullWidth
                id="email"
                label="Email Address"
                name="email"
                autoComplete="email"
                onChange={({ target }) => setEmail(target.value)}
              />
            </Grid>

            <Grid item xs={12}>
              <TextField
                variant="outlined"
                required
                fullWidth
                name="password"
                label="Password"
                type="password"
                id="password"
                autoComplete="current-password"
                onChange={({ target }) => setPassword(target.value)}
              />
            </Grid>
          </Grid>

          <Button
            type="submit"
            fullWidth
            variant="contained"
            color="primary"
            className={classes.submit}
          >
            Sign Up
          </Button>

          <Button
            type="submit"
            fullWidth
            variant="contained"
            color="secondary"
            className={classes.signin}
          >
            <Link to="/">Already have an account? Sign In</Link>
          </Button>
        </form>
      </div>
    </Container>
  );
};
