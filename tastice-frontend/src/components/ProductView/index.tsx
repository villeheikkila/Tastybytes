import React from "react";
import { ProductCard } from "../ProductCard"
import { IProduct } from "../../types";
import { makeStyles } from '@material-ui/core/styles';
import Grid from '@material-ui/core/Grid';

const useStyles = makeStyles(theme => ({
    root: {
        flexGrow: 1,
        overflow: 'hidden',
        padding: theme.spacing(0, 0),
    }
}));

export const ProductView = () => {
    const classes = useStyles();

    const products: IProduct[] = [{
        id: "asdd",
        name: "Lipton Green Tea",
        producer: "Nestle",
        type: "Virvoitusjuoma",
        subType: "Jäätee",
        dateAdded: "March 23, 2019",
        imgURL: "https://pixel.nymag.com/imgs/daily/vulture/2018/11/02/02-avatar-2.w700.h467.jpg",
        firstName: "Ville",
        lastName: "Heikkilä"
    },
    {
        id: "asdd",
        name: "Lipton Green Tea",
        producer: "Nestle",
        type: "Virvoitusjuoma",
        subType: "Jäätee",
        dateAdded: "March 23, 2019",
        imgURL: "https://pixel.nymag.com/imgs/daily/vulture/2018/11/02/02-avatar-2.w700.h467.jpg",
        firstName: "Ville",
        lastName: "Heikkilä"
    },
    {
        id: "asdd",
        name: "Lipton Green Tea",
        producer: "Nestle",
        type: "Virvoitusjuoma",
        subType: "Jäätee",
        dateAdded: "March 23, 2019",
        imgURL: "https://pixel.nymag.com/imgs/daily/vulture/2018/11/02/02-avatar-2.w700.h467.jpg",
        firstName: "Ville",
        lastName: "Heikkilä"
    }]

    return (
        <div className={classes.root}>
            <Grid container justify="center" spacing={10}>
                <Grid item xs={12}>
                    {products.map((product: IProduct) => ProductCard(product))}
                </Grid>
            </Grid>
        </div>
    )
}