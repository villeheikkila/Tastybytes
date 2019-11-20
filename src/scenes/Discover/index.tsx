import { useQuery } from '@apollo/react-hooks';
import { Card, Fab, Grid, makeStyles, Typography } from '@material-ui/core';
import AddIcon from '@material-ui/icons/Add';
import React, { Fragment } from 'react';
import { Link } from 'react-router-dom';
import { Waypoint } from 'react-waypoint';
import { Loading } from '../../components/Loading';
import { ProductCard } from '../../components/ProductCard';
import { FILTER, SEARCH_PRODUCTS } from '../../graphql';

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
    const classes = useStyles({});
    const { data: filterData, client } = useQuery(FILTER);

    const { data, fetchMore } = useQuery(SEARCH_PRODUCTS, {
        variables: { filter: filterData.filter, first: 5 },
        onError: error => {
            client.writeData({
                data: {
                    notification: error.message,
                    variant: 'error',
                },
            });
        },
    });

    if (!data || !data.searchProducts) return <Loading />;

    const loadMore = (): void => {
        fetchMore({
            variables: {
                skip: data.searchProducts.length,
            },
            updateQuery: (prev: any, { fetchMoreResult }) => {
                if (!fetchMoreResult) return prev;
                return Object.assign({}, prev, {
                    searchProducts: [...prev.searchProducts, ...fetchMoreResult.searchProducts],
                });
            },
        });
    };

    const products = data.searchProducts;
    const noResults = products.length === 0;

    return (
        <div className={classes.root}>
            {noResults && <Typography variant="h5">No products found</Typography>}

            <Grid container justify="center" spacing={10}>
                <Grid item xs={12}>
                    {products.map(
                        (product: Product, index: number): JSX.Element => (
                            <Fragment key={product.id.toUpperCase()}>
                                {data.searchProducts.length - index <= 1 && <Waypoint onEnter={loadMore} />}
                                <Card key={product.id} className={classes.card}>
                                    <ProductCard key={product.id} product={product} showMenu={false} />
                                </Card>
                            </Fragment>
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
