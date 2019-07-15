import React, { useState } from "react";
import { useQuery, useMutation } from "@apollo/react-hooks";
import { ME, DELETE_USER, UPDATE_USER } from "../../queries";

import { Theme, createStyles, makeStyles } from "@material-ui/core/styles";
import Paper from "@material-ui/core/Paper";
import Avatar from "@material-ui/core/Avatar";
import Typography from "@material-ui/core/Typography";
import TextField from "@material-ui/core/TextField";
import Button from "@material-ui/core/Button";
import { notificationHandler, errorHandler } from "../../utils";
import history from "../../utils/history";
import { Token } from "../../types";

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
      width: 150,
      height: 150
    },
    container: {
      display: "flex",
      flexWrap: "wrap",
      flexDirection: "column"
    },
    textField: {
      marginLeft: theme.spacing(1),
      marginRight: theme.spacing(1),
      width: 200
    },
    button: {
      marginTop: 30
    }
  })
);

export const Profile: React.FC<Token> = ({ setToken }) => {
  const me = useQuery(ME);
  const [firstName, setFirstName] = useState("");
  const [lastName, setLastName] = useState("");
  const [email, setEmail] = useState("");

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

  return (
    <div>
      <Paper className={classes.paper}>
        <Typography variant="h5" component="h3">
          {user.name}
        </Typography>

        <Avatar
          alt="Avatar"
          src="https://pixel.nymag.com/imgs/daily/vulture/2018/11/02/02-avatar-2.w700.h467.jpg"
          className={classes.Avatar}
        />
        <Typography variant="h5">Checkins: 10</Typography>

        <TextField
          label="First Name"
          id="margin-normal"
          defaultValue={user.firstName}
          className={classes.textField}
          onChange={({ target }) => setFirstName(target.value)}
          margin="normal"
        />
        <TextField
          label="Last Name"
          id="margin-normal"
          defaultValue={user.lastName}
          className={classes.textField}
          onChange={({ target }) => setLastName(target.value)}
          margin="normal"
        />
        <TextField
          label="Email"
          id="margin-normal"
          defaultValue={user.email}
          className={classes.textField}
          onChange={({ target }) => setEmail(target.value)}
          margin="normal"
        />
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
      </Paper>
    </div>
  );
};
