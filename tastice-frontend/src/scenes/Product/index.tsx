import { useQuery } from '@apollo/react-hooks';
import { Card, makeStyles } from '@material-ui/core';
import React, { useState } from 'react';
import { CheckInCard } from '../../components/CheckInCard';
import { Divider } from '../../components/Divider';
import { ProductCard } from '../../components/ProductCard';
import { ME, PRODUCT } from '../../graphql';
import { CreateCheckIn } from './CreateCheckIn';

const useStyles = makeStyles(theme => ({
    card: {
        maxWidth: 700,
        margin: `${theme.spacing(1)}px auto`,
    },
}));

export const Product = ({ id }: IdObject): JSX.Element | null => {
    const me = useQuery(ME);
    const [submitted, setSubmitted] = useState();
    const classes = useStyles();
    const productsQuery = useQuery(PRODUCT, {
        variables: { id },
    });

    if (me.data.me === undefined || productsQuery.data === undefined || productsQuery.data.product === undefined) {
        return null;
    }

    const product = productsQuery.data.product[0];

    const dividerText = product.checkins.length === 0 ? 'No Recent Activity' : 'Recent Activity';

    // Workaround due to fact that Prisma can't order nested fields
    const reverseOrderCheckins = product.checkins.reverse();

    return (
        <>
            <Card className={classes.card}>
                <ProductCard product={product} showMenu={true} />
            </Card>

            {!submitted && (
                <CreateCheckIn authorId={me.data.me.id} productId={product.id} setSubmitted={setSubmitted} />
            )}

            <Divider text={dividerText} />

            {reverseOrderCheckins.map(
                (checkin: CheckInObject): JSX.Element => (
                    <CheckInCard key={checkin.id} checkin={checkin} showProduct={false} />
                ),
            )}
        </>
    );
};
