import React, { useState } from "react";
import { useQuery, useMutation } from "@apollo/react-hooks";
import { PRODUCT, CREATE_CHECKIN, ALL_CHECKINS, ME } from "../../queries";
import { ProductCard } from "../ProductCard";
import { Divider } from "../Divider";
import { CheckInCard } from "../CheckInCard";
import { CreateCheckIn } from "../CreateCheckIn";
import { Theme, createStyles, makeStyles } from "@material-ui/core/styles";
import Paper from "@material-ui/core/Paper";
import TextField from "@material-ui/core/TextField";
import Typography from "@material-ui/core/Typography";
import Rating from "material-ui-rating";
import Grid from "@material-ui/core/Grid";
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

export const ProductPage: React.FC<any> = id => {
  const classes = useStyles();
  const me = useQuery(ME);
  const productsQuery = useQuery(PRODUCT, {
    variables: { id: id.id }
  });

  if (
    productsQuery.data === undefined ||
    productsQuery.data.product === undefined
  ) {
    return null;
  }

  const product = productsQuery.data.product[0];
  console.log("product: ", product);
  const user = me.data.me;

  const productObject = {
    id: product.id,
    name: product.name,
    producer: product.producer,
    category: product.type,
    subCategory: product.type
  };

  return (
    <>
      <ProductCard product={productObject} />
      <CreateCheckIn authorId={me.data.me.id} productId={product.id} />
      <Divider text={"Recent Activity"} />

      <Grid container justify="center" spacing={10}>
        <Grid item xs={12}>
          {user.checkins.map((checkin: any) => (
            <CheckInCard key={checkin.createdAt} checkin={checkin} />
          ))}
        </Grid>
      </Grid>
    </>
  );
};
