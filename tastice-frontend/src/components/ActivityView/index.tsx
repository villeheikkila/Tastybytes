import React from "react";
import { CheckInCard } from "../CheckInCard";
import { useQuery } from "@apollo/react-hooks";
import { ALL_CHECKINS } from "../../queries";
import { Grid, makeStyles } from "@material-ui/core";

const useStyles = makeStyles(theme => ({
  root: {
    flexGrow: 1,
    overflow: "hidden",
    maxWidth: 700,
    margin: `${theme.spacing(1)}px auto`,
    alignContent: "center"
  },
  fab: {
    margin: 0,
    top: "auto",
    right: 30,
    bottom: 70,
    position: "fixed"
  }
}));

export const ActivityView = () => {
  const classes = useStyles();
  const checkins = useQuery(ALL_CHECKINS);

  if (checkins === undefined || checkins.data.checkins === undefined) {
    return null;
  }

  return (
    <div className={classes.root}>
      <Grid container justify="center" spacing={10}>
        <Grid item xs={12}>
          {checkins.data.checkins.map((checkin: any) => (
            <CheckInCard key={checkin.createdAt} checkin={checkin} />
          ))}
        </Grid>
      </Grid>
    </div>
  );
};
