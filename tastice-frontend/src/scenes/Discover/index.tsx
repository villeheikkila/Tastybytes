import React from 'react';
import { ProductCard } from '../../components/ProductCard';
import { Product } from '../../types';
import { useQuery } from '@apollo/react-hooks';
import { SEARCH_PRODUCTS, FILTER } from '../../queries';
import { Link } from 'react-router-dom';

import AddIcon from '@material-ui/icons/Add';
import { Grid, Fab, makeStyles, Card } from '@material-ui/core';
import { errorHandler } from '../../utils';

const useStyles = makeStyles(theme => ({
    root: {
        flexGrow: 1,
        overflow: 'hidden',
        maxWidth: 700,
        margin: `${theme.spacing(1)}px auto`,
        alignContent: 'center',
    },
    card: {
        margin: `${theme.spacing(1)}px auto`,
    },
    fab: {
        margin: 0,
        top: 'auto',
        right: 30,
        bottom: 70,
        position: 'fixed',
    },
}));

export const Discover = () => {
    const classes = useStyles();
    const filter = useQuery(FILTER);
    const searchProductsQuery = useQuery(SEARCH_PRODUCTS, {
        variables: { name: filter.data.filter },
        onError: errorHandler,
    });

    const products = searchProductsQuery.data.searchProducts;

    if (products === undefined) {
        return null;
    }

    return (
        <div className={classes.root}>
            <Grid container justify="center" spacing={10}>
                <Grid item xs={12}>
                    {products.map((product: Product) => (
                        <Card key={product.id} className={classes.card}>
                            <ProductCard key={product.id} product={product} showMenu={false} />
                        </Card>
                    ))}
                </Grid>
            </Grid>
            <Fab color="secondary" aria-label="Add" className={classes.fab} component={Link} to="/product/new">
                <AddIcon />
            </Fab>
        </div>
    );
};
