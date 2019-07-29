import React from 'react';
import { useQuery } from '@apollo/react-hooks';
import { PRODUCT, ME } from '../../queries';
import { ProductCard } from '../../components/ProductCard';
import { Divider } from '../../components/Divider';
import { CheckInCard } from '../../components/CheckInCard';
import { CreateCheckIn } from './CreateCheckIn';
import { makeStyles, Card } from '@material-ui/core';

const useStyles = makeStyles(theme => ({
    card: {
        maxWidth: 700,
        margin: `${theme.spacing(1)}px auto`,
    },
}));

export const Product = (id: IdObject): JSX.Element | null => {
    const me = useQuery(ME);
    const classes = useStyles();
    const productsQuery = useQuery(PRODUCT, {
        variables: { id: id.id },
    });

    if (me.data === undefined || productsQuery.data === undefined || productsQuery.data.product === undefined) {
        return null;
    }

    const product = productsQuery.data.product[0];

    const productObject = {
        id: product.id,
        name: product.name,
        company: product.company,
        category: product.category,
        subCategory: product.subCategory,
    };

    const dividerText = product.checkins.length === 0 ? 'No Recent Activity' : 'Recent Activity';

    return (
        <>
            <Card className={classes.card}>
                <ProductCard product={productObject} showMenu={true} />
            </Card>
            <CreateCheckIn authorId={me.data.me.id} productId={product.id} />
            <Divider text={dividerText} />

            {product.checkins.map(
                (checkin: CheckInObject): JSX.Element => (
                    <CheckInCard key={checkin.id} checkin={checkin} showProduct={false} />
                ),
            )}
        </>
    );
};
