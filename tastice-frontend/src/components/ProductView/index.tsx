import React from "react";
import { ProductCard } from "../ProductCard";
import { IProduct } from "../../types";
import { makeStyles } from "@material-ui/core/styles";
import Grid from "@material-ui/core/Grid";
import Fab from "@material-ui/core/Fab";
import AddIcon from "@material-ui/icons/Add";
import history from "../../utils/history";

const useStyles = makeStyles(theme => ({
  root: {
    flexGrow: 1,
    overflow: "hidden",
    padding: theme.spacing(0, 0),
    alignContent: "center"
  },
  margin: {
    margin: theme.spacing(1)
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

  const handleAdd = () => {
    history.push("/addproduct");
  };

  const products: IProduct[] = [
    {
      id: "asdd",
      name: "Lipton Green Tea",
      producer: "Nestle",
      type: "Virvoitusjuoma",
      subType: "Jäätee",
      dateAdded: "March 23, 2019",
      imgURL:
        "https://pixel.nymag.com/imgs/daily/vulture/2018/11/02/02-avatar-2.w700.h467.jpg",
      firstName: "Ville",
      lastName: "Heikkilä"
    },
    {
      id: "asdxxxd",
      name: "Lipton Green Tea",
      producer: "Nestle",
      type: "Virvoitusjuoma",
      subType: "Jäätee",
      dateAdded: "March 23, 2019",
      imgURL:
        "https://pixel.nymag.com/imgs/daily/vulture/2018/11/02/02-avatar-2.w700.h467.jpg",
      firstName: "Ville",
      lastName: "Heikkilä"
    },
    {
      id: "asdddd",
      name: "Lipton Green Tea",
      producer: "Nestle",
      type: "Virvoitusjuoma",
      subType: "Jäätee",
      dateAdded: "March 23, 2019",
      imgURL:
        "https://pixel.nymag.com/imgs/daily/vulture/2018/11/02/02-avatar-2.w700.h467.jpg",
      firstName: "Ville",
      lastName: "Heikkilä"
    }
  ];

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
