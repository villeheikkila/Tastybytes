import React, { useState } from "react";
import { useQuery, useMutation } from "@apollo/react-hooks";
import { PRODUCT, CREATE_CHECKIN, ALL_CHECKINS, ME } from "../../queries";
import { ProductCard } from "../ProductCard";
import { Theme, createStyles, makeStyles } from "@material-ui/core/styles";
import Paper from "@material-ui/core/Paper";
import TextField from "@material-ui/core/TextField";
import Typography from "@material-ui/core/Typography";
import Rating from "material-ui-rating";
import Button from "@material-ui/core/Button";
import { notificationHandler, errorHandler } from "../../utils";

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

export const CreateCheckIn: React.FC<any> = id => {
  const classes = useStyles();
  const productsQuery = useQuery(PRODUCT, {
    variables: { id: id.id }
  });
  const [rating, setRating] = useState();
  const [comment, setComment] = useState();
  const me = useQuery(ME);

  const [createCheckin] = useMutation(CREATE_CHECKIN, {
    onError: errorHandler,
    refetchQueries: [{ query: ALL_CHECKINS }, { query: ME }]
  });

  if (
    productsQuery.data === undefined ||
    productsQuery.data.product === undefined
  ) {
    return null;
  }
  const product = productsQuery.data.product[0];
  const user = me.data.me;

  const producta = {
    id,
    name: product.name,
    producer: product.producer,
    category: product.type,
    subCategory: product.type
  };

  const handeCheckIn = async () => {
    const result = await createCheckin({
      variables: {
        authorId: user.id,
        productId: product.id,
        comment: comment,
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
      <ProductCard product={producta} show={false} />

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
