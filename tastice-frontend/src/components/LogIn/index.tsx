import React, { useState } from "react";
import { ILogIn } from "../../types";
import { Link } from "react-router-dom";
import { LOGIN } from "./queries";
import { useMutation } from "@apollo/react-hooks";
import { Notifications } from "../Notification";
import Button from "@material-ui/core/Button";
import CssBaseline from "@material-ui/core/CssBaseline";
import TextField from "@material-ui/core/TextField";
import Typography from "@material-ui/core/Typography";
import { makeStyles } from "@material-ui/core/styles";
import Container from "@material-ui/core/Container";

const useStyles = makeStyles(theme => ({
  paper: {
    marginTop: theme.spacing(8),
    display: "flex",
    flexDirection: "column",
    alignItems: "center"
  },
  form: {
    marginTop: theme.spacing(1)
  },
  submit: {
    margin: theme.spacing(3, 0, 2)
  },
  signup: {
    margin: theme.spacing(0, 0, 0)
  },
  image: {
    marginBottom: theme.spacing(2)
  }
}));

export const LogIn: React.FC<ILogIn> = ({ setToken }) => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const classes = useStyles();

  const handleError = (error: any) => {
    console.log("error:", error.message);
  };

  const [login] = useMutation(LOGIN, {
    onError: handleError
  });

  const handleLogin = async (
    event: React.FormEvent<HTMLFormElement>
  ): Promise<void> => {
    event.preventDefault();

    const result = await login({
      variables: { email, password }
    });

    if (result) {
      const token = result.data.login.token;
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
          src="https://fontmeme.com/permalink/190709/2864eb8c1c66dd28b0eb795fc422ff02.png"
          alt="logo"
        />

        <Typography component="h1" variant="h5">
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
            onChange={({ target }) => setEmail(target.value)}
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
            onChange={({ target }) => setPassword(target.value)}
          />

          <Button
            type="submit"
            fullWidth
            variant="contained"
            color="primary"
            className={classes.submit}
          >
            Sign In
          </Button>

          <Button
            type="submit"
            fullWidth
            variant="contained"
            color="secondary"
            className={classes.signup}
          >
            <Link to="/signup">{"Don't have an account? Sign Up"}</Link>
          </Button>
        </form>
      </div>
    </Container>
  );
};
