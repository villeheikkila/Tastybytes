import { useQuery } from '@apollo/react-hooks';
import { Card, Fab, Grid, makeStyles, Typography } from '@material-ui/core';
import AddIcon from '@material-ui/icons/Add';
import React from 'react';
import { Link } from 'react-router-dom';
import { ProductCard } from '../../components/ProductCard';
import { FILTER, SEARCH_PRODUCTS } from '../../graphql';
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

export const Discover = (): JSX.Element | null => {
    const classes = useStyles();
    const filter = useQuery(FILTER);

    const searchProductsQuery = useQuery(SEARCH_PRODUCTS, {
        variables: { filter: filter.data.filter },
        onError: errorHandler,
    });

    if (searchProductsQuery === undefined || searchProductsQuery.data.searchProducts === undefined) {
        return null;
    }

    const products = searchProductsQuery.data.searchProducts;
    const noResults = products.length === 0;

    return (
        <div className={classes.root}>
            {noResults && <Typography variant="h5">No products found</Typography>}

            <Grid container justify="center" spacing={10}>
                <Grid item xs={12}>
                    {products.map(
                        (product: Product): JSX.Element => (
                            <Card key={product.id} className={classes.card}>
                                <ProductCard key={product.id} product={product} showMenu={false} />
                            </Card>
                        ),
                    )}
                </Grid>
            </Grid>
            <Fab color="secondary" aria-label="Add" className={classes.fab} component={Link} to="/product/new">
                <AddIcon />
            </Fab>
        </div>
    );
};
