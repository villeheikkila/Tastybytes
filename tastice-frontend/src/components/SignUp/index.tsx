import React, { useState } from "react";
import { SIGN_UP } from "../../queries";
import { useMutation } from "@apollo/react-hooks";
import { Link } from "react-router-dom";
import { ILogIn } from "../../types";
import history from '../../utils/history';

import Button from "@material-ui/core/Button";
import CssBaseline from "@material-ui/core/CssBaseline";
import TextField from "@material-ui/core/TextField";
import Grid from "@material-ui/core/Grid";
import Typography from "@material-ui/core/Typography";
import { makeStyles } from "@material-ui/core/styles";
import Container from "@material-ui/core/Container";
import { errorHandler } from "../../utils";
import { ValidatorForm, TextValidator } from "react-material-ui-form-validator";

const useStyles = makeStyles(theme => ({
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

export const SignUp: React.FC<ILogIn> = ({ setToken }) => {
  const [firstName, setFirstName] = useState("");
  const [lastName, setLastName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const classes = useStyles();

  const [signup] = useMutation(SIGN_UP, {
    onError: errorHandler
  });

  const handleSignUp = async (event: any) => {
    event.preventDefault();

    const result = await signup({
      variables: { firstName, lastName, email, password }
    });

    if (result) {
      const token = result.data.signup.token;
      setToken(token);
      localStorage.setItem("token", token);
    }
  };

  const handlePushToLogin = () => history.push("/")

  const handlePasswordChange = (event: any) => setPassword(event.target.value)

  const handleEmailChange = (event: any) => setEmail(event.target.value)

  const handleLastNameChange = (event: any) => setLastName(event.target.value);

  const handleFirstNameChange = (event: any) => setFirstName(event.target.value)

  return (
    <Container component="main" maxWidth="xs">
      <CssBaseline />
      <div className={classes.paper}>
        <img
          className={classes.image}
          src="https://fontmeme.com/permalink/190709/2864eb8c1c66dd28b0eb795fc422ff02.png"
          alt="logo"
        />

        <Typography component="h1" variant="h5">
          Sign up
        </Typography>
        <ValidatorForm
          onSubmit={handleSignUp}
          onError={(errors: any) => console.log(errors)}
        >
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
                errorMessages={['This field is required', 'The name is too short', 'The name is too long']}
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
                errorMessages={['This field is required', 'The name is too short', 'The name is too long']}
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
                errorMessages={['This field is required', 'The entered password is too short', 'The entered password is too long']}
                value={password}
                onChange={handlePasswordChange}
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
            onClick={handlePushToLogin}
          >
            Already have an account? Sign In!
          </Button>
        </ValidatorForm>
      </div>
    </Container>
  );
};
