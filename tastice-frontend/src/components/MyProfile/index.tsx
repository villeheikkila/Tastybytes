import React from "react";
import { useQuery } from "@apollo/react-hooks";
import { ME } from "../../queries";

import { Theme, createStyles, makeStyles } from "@material-ui/core/styles";
import Paper from "@material-ui/core/Paper";
import Avatar from "@material-ui/core/Avatar";
import Typography from "@material-ui/core/Typography";

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

export const MyProfile = () => {
  const me = useQuery(ME);
  const classes = useStyles();

  if (me.data.me === undefined) {
    return null;
  }

  const user = me.data.me;

  return (
    <div>
      <Paper className={classes.paper}>
        <Typography variant="h4" component="h3" className={classes.textField}>
          {user.firstName} {user.lastName}
        </Typography>
        <Avatar
          alt="Avatar"
          src="https://pixel.nymag.com/imgs/daily/vulture/2018/11/02/02-avatar-2.w700.h467.jpg"
          className={classes.Avatar}
        />
        <Typography variant="h4" component="h3" className={classes.textField}>
          Checkins in total: 15
        </Typography>
      </Paper>
    </div>
  );
};
