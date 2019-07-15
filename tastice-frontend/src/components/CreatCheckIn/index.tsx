import React, { useState } from "react";
import { useQuery, useMutation } from "@apollo/react-hooks";
import { PRODUCT } from "../../queries";
import { ProductCard } from "../ProductCard";
import { Theme, createStyles, makeStyles } from "@material-ui/core/styles";
import Paper from "@material-ui/core/Paper";
import TextField from "@material-ui/core/TextField";
import Typography from "@material-ui/core/Typography";
import Rating from "material-ui-rating";
import Button from "@material-ui/core/Button";

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
  console.log("rating: ", rating);
  const [comment, setComment] = useState();
  console.log("comment: ", comment);

  if (
    productsQuery.data === undefined ||
    productsQuery.data.product === undefined
  ) {
    return null;
  }
  console.log("productsQuery: ", productsQuery);
  console.log("length", productsQuery.data.leng);

  const product = productsQuery.data.product[0];

  const producta = {
    id,
    name: product.name,
    producer: product.producer,
    category: product.type,
    subCategory: product.type
  };

  const handeCheckIn = () => {
    console.log("moi");
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
