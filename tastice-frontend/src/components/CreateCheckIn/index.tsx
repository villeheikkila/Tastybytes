import React, { useState } from "react";
import { useMutation } from "@apollo/react-hooks";
import { CREATE_CHECKIN, ALL_CHECKINS, ME } from "../../queries";
import { Theme, createStyles, makeStyles } from "@material-ui/core/styles";
import Paper from "@material-ui/core/Paper";
import TextField from "@material-ui/core/TextField";
import Typography from "@material-ui/core/Typography";
import Rating from "material-ui-rating";
import Button from "@material-ui/core/Button";
import { notificationHandler, errorHandler } from "../../utils";
import { ICreateCheckIn } from "../../types";

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    paper: {
      padding: theme.spacing(3, 2),
      maxWidth: 700,
      margin: `${theme.spacing(1)}px auto`,
      display: "flex",
      flexDirection: "column"
    },
    textField: {
      marginLeft: theme.spacing(1),
      marginRight: theme.spacing(1)
    },
    button: {
      margin: theme.spacing(1)
    }
  })
);

export const CreateCheckIn: React.FC<ICreateCheckIn> = ({
  authorId,
  productId
}) => {
  const classes = useStyles();
  const [rating, setRating] = useState();
  const [comment, setComment] = useState();
  const [createCheckin] = useMutation(CREATE_CHECKIN, {
    onError: errorHandler,
    refetchQueries: [{ query: ALL_CHECKINS }, { query: ME }]
  });

  const handeCheckIn = async () => {
    const result = await createCheckin({
      variables: {
        authorId: authorId,
        productId: productId,
        comment,
        rating
      }
    });

    if (result) {
      notificationHandler({
        message: `Checkin for '${
          result.data.createCheckin.product.name
        }' succesfully added`,
        variant: "success"
      });
    }
  };

  return (
    <div>
      <Paper className={classes.paper}>
        <Typography variant="h5" component="h3">
          How did you like it?
        </Typography>
        <TextField
          id="outlined-multiline-static"
          label="Comments"
          multiline
          rows="4"
          className={classes.textField}
          margin="normal"
          variant="outlined"
          onChange={(event: any) => setComment(event.target.value)}
        />
        <Typography component="p">Rating</Typography>
        <Rating value={rating} max={5} onChange={(i: any) => setRating(i)} />
        <Button
          variant="contained"
          color="primary"
          className={classes.button}
          onClick={handeCheckIn}
        >
          Check-in!
        </Button>
      </Paper>
    </div>
  );
};
