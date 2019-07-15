import React, { useState } from "react";
import { useQuery, useMutation } from "@apollo/react-hooks";
import { ME, DELETE_USER, UPDATE_USER } from "../../queries";

import { Theme, createStyles, makeStyles } from "@material-ui/core/styles";
import Paper from "@material-ui/core/Paper";
import Avatar from "@material-ui/core/Avatar";
import Typography from "@material-ui/core/Typography";
import Grid from "@material-ui/core/Grid";
import Button from "@material-ui/core/Button";
import { notificationHandler, errorHandler } from "../../utils";
import history from "../../utils/history";
import { Token } from "../../types";
import { ValidatorForm, TextValidator } from "react-material-ui-form-validator";

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    paper: {
      marginTop: 30,
      maxWidth: 700,
      padding: theme.spacing(3, 2),
      margin: `${theme.spacing(1)}px auto`,
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      alignContent: "center"
    },
    Avatar: {
      marginLeft: 30,
      marginRight: 30,
      marginTop: 15,
      marginBottom: 15,
      width: 150,
      height: 150
    },
    container: {
      display: "flex",
      flexWrap: "wrap",
      flexDirection: "column"
    },
    textField: {
      marginTop: 10
    },
    button: {
      marginTop: 30
    },
    form: { padding: theme.spacing(3, 0) }
  })
);

export const Account: React.FC<Token> = ({ setToken }) => {
  const me = useQuery(ME);
  const [firstName, setFirstName] = useState();
  const [lastName, setLastName] = useState();
  const [email, setEmail] = useState();

  const [deleteUser] = useMutation(DELETE_USER, {
    onError: error => console.log(error)
  });
  const [updateUser] = useMutation(UPDATE_USER, {
    onError: errorHandler
  });
  const classes = useStyles();

  if (me.data.me === undefined) {
    return null;
  }

  const user = me.data.me;

  const handleUpdateUser = async (event: any) => {
    const result = await updateUser({
      variables: {
        id: user.id,
        firstName: firstName || user.firstName,
        lastName: lastName || user.lastName,
        email: email || user.email
      }
    });

    if (result) {
      notificationHandler({
        message: `User '${
          result.data.updateUser.firstName
        }' succesfully updated`,
        variant: "success"
      });
    }
  };

  const handleDeleteUser = async () => {
    await deleteUser({
      variables: { id: user.id }
    });
    localStorage.clear();
    setToken(null);
    history.push("/");
  };

  const handleEmailChange = (event: any) => setEmail(event.target.value);

  const handleLastNameChange = (event: any) => setLastName(event.target.value);

  const handleFirstNameChange = (event: any) =>
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

        <ValidatorForm
          onSubmit={handleUpdateUser}
          className={classes.form}
          onError={(errors: any) => console.log(errors)}
        >
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
                validators={[
                  "required",
                  "minStringLength: 3",
                  "maxStringLength: 12"
                ]}
                errorMessages={[
                  "This field is required",
                  "The name is too short",
                  "The name is too long"
                ]}
                value={firstName}
                defaultValue={user.firstName}
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
                validators={[
                  "required",
                  "minStringLength: 3",
                  "maxStringLength: 12"
                ]}
                errorMessages={[
                  "This field is required",
                  "The name is too short",
                  "The name is too long"
                ]}
                value={lastName}
                defaultValue={user.lastName}
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
                validators={["required", "isEmail"]}
                errorMessages={[
                  "This field is required",
                  "The entered email is not valid"
                ]}
                value={email}
                defaultValue={user.email}
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
              onClick={handleDeleteUser}
            >
              Delete User
            </Button>
          </Grid>
        </ValidatorForm>
      </Paper>
    </div>
  );
};
