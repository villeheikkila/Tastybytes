import { useQuery } from '@apollo/react-hooks';
import { Card, makeStyles } from '@material-ui/core';
import React, { Fragment, useEffect, useState } from 'react';
import { Waypoint } from 'react-waypoint';
import { CheckInCard } from '../../components/CheckInCard';
import { Divider } from '../../components/Divider';
import { Loading } from '../../components/Loading';
import { ProductCard } from '../../components/ProductCard';
import { FILTER, PRODUCT } from '../../graphql';
import { SEARCH_PRODUCT_CHECKINS } from '../../graphql/checkin';
import { CreateCheckIn } from './CreateCheckIn';

const useStyles = makeStyles(theme => ({
    card: {
        maxWidth: 700,
        margin: `${theme.spacing(1)}px auto`,
    },
}));

export const Product = ({ id }: IdObject): JSX.Element => {
    const [submitted, setSubmitted] = useState();
    const classes = useStyles({});
    const { loading: filterLoading, data: filterData, client } = useQuery(FILTER);

    const productsQuery = useQuery(PRODUCT, {
        variables: { id },
    });

    const { loading, data, fetchMore } = useQuery(SEARCH_PRODUCT_CHECKINS, {
        variables: { id: id, filter: filterData.filter, first: 5 },
        onError: error => {
            client.writeData({
                data: {
                    notification: error.message,
                    variant: 'error',
                },
            });
        },
    });

    //scroll to the top of the page to reset the position
    useEffect(() => {
        window.scrollTo(0, 0);
    }, []);

    if (filterLoading || loading || productsQuery.loading || !data) return <Loading />;

    // This needs to be moved to backend at some point.
    const loadMore = (): void => {
        fetchMore({
            variables: {
                skip: data.searchProductCheckins.length,
            },
            updateQuery: (prev: any, { fetchMoreResult }) => {
                if (!fetchMoreResult) return prev;
                return Object.assign({}, prev, {
                    searchProductCheckins: [...prev.searchProductCheckins, ...fetchMoreResult.searchProductCheckins],
                });
            },
        });
    };

    const product = productsQuery.data.product[0];

    const dividerText = product.checkins.length === 0 ? 'No Recent Activity' : 'Recent Activity';

    return (
        <>
            <Card className={classes.card}>
                <ProductCard product={product} showMenu={true} />
            </Card>

            {!submitted && <CreateCheckIn productId={product.id} setSubmitted={setSubmitted} />}

            <Divider text={dividerText} />

            {data.searchProductCheckins.map(
                (checkin: CheckInObject, index: number): JSX.Element => (
                    <Fragment key={index}>
                        {data.searchProductCheckins.length - index <= 1 && <Waypoint onEnter={loadMore} />}
                        <CheckInCard key={checkin.id} checkin={checkin} showProduct={false} />
                    </Fragment>
                ),
            )}
        </>
    );
};
