import React from "react";
import { ProductCard } from "../ProductCard";
import { IProduct } from "../../types";
import { makeStyles } from "@material-ui/core/styles";
import Grid from "@material-ui/core/Grid";
import Fab from "@material-ui/core/Fab";
import AddIcon from "@material-ui/icons/Add";
import history from "../../utils/history";
import { useQuery } from "@apollo/react-hooks";
import { ALL_PRODUCTS } from "../../queries";

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

export const ProductView = () => {
  const classes = useStyles();
  const productsQuery = useQuery(ALL_PRODUCTS);
  const products = productsQuery.data.products;

  if (products === undefined) {
    return null;
  }

  const handleAdd = () => {
    history.push("/addproduct");
  };

  return (
    <div className={classes.root}>
      <Grid container justify="center" spacing={10}>
        <Grid item xs={12}>
          {products.map((product: IProduct) => (
            <ProductCard key={product.id} product={product} />
          ))}
        </Grid>
      </Grid>
      <Fab
        color="secondary"
        aria-label="Add"
        className={classes.fab}
        onClick={handleAdd}
      >
        <AddIcon />
      </Fab>
    </div>
  );
};
