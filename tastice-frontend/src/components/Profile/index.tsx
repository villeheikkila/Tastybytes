import React from "react";
import { useQuery } from "@apollo/react-hooks";
import { USER } from "../../queries";

import { Theme, createStyles, makeStyles } from "@material-ui/core/styles";
import Paper from "@material-ui/core/Paper";
import Avatar from "@material-ui/core/Avatar";
import Typography from "@material-ui/core/Typography";
import { ALL_CHECKINS } from "../../queries";
import Grid from "@material-ui/core/Grid";
import { DetailedCheckInCard } from "../DetailedCheckInCard";

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
    textField: {
      marginTop: 10
    },
    button: {
      marginTop: 30
    },
    form: { padding: theme.spacing(3, 0) },
    root: {
      display: "flex",
      flexDirection: "column",
      alignItems: "center"
    }
  })
);

export const Profile: React.FC<any> = id => {
  const classes = useStyles();
  const user = useQuery(USER, {
    variables: { id: id.id }
  });

  console.log("user: ", user);

  if (user.data.user === undefined) {
    return null;
  }

  const userObject = {
    firstName: user.data.user[0].firstName,
    lastName: user.data.user[0].lastName,
    checkins: user.data.user[0].checkins
  };
  console.log("userObject: ", userObject);

  return (
    <div className={classes.root}>
      <Paper className={classes.paper}>
        <Typography variant="h4" component="h3" className={classes.textField}>
          {userObject.firstName} {userObject.lastName}
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
      <Typography variant="h4" component="h3" className={classes.textField}>
        Activity
      </Typography>
      <Grid container justify="center" spacing={10}>
        <Grid item xs={12}>
          {userObject.checkins.map((checkin: any) => (
            <DetailedCheckInCard key={checkin.createdAt} checkin={checkin} />
          ))}
        </Grid>
      </Grid>
    </div>
  );
};
