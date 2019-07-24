import React from 'react';
import { Link as RouterLink } from 'react-router-dom';
import useReactRouter from 'use-react-router';
import { ProductObject } from '../../types';
import lipton from '../../images/lipton.jpg';

import { Card, Link, Avatar, Typography, CardContent, CardActionArea, makeStyles, Chip } from '@material-ui/core';

const useStyles = makeStyles(theme => ({
    card: {
        maxWidth: 700,
        margin: `${theme.spacing(1)}px auto`,
        display: 'flex',
    },
    actionArea: {
        display: 'flex',
        flexDirection: 'row',
        justifyContent: 'left',
    },
    picture: {
        margin: 10,
        width: 100,
        height: 100,
    },
    content: {
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'left',
    },
    chips: {
        display: 'flex',
        flexDirection: 'row',
    },
    chip: {
        margin: theme.spacing(0.3),
    },
}));

export const ProductCard: React.FC<ProductObject> = ({ product }) => {
    const classes = useStyles();
    const { history } = useReactRouter();
    const { id, name, producer, category, subCategory } = product;

    return (
        <Card className={classes.card}>
            <CardActionArea onClick={() => history.push(`/product/${id}`)} className={classes.actionArea}>
                <Avatar alt="Image" src={lipton} className={classes.picture} />
                <CardContent className={classes.content}>
                    <Typography variant="h4" color="textSecondary" component="h4">
                        <Link component={RouterLink} to={`/product/${id}`}>
                            {name}
                        </Link>
                    </Typography>

                    <Typography variant="h5" color="textPrimary" component="h5">
                        {producer}
                    </Typography>

                    {category.map((e: any) => (
                        <Chip label={e.name} className={classes.chip} color="inherit" />
                    ))}
                    <div className={classes.chips}>
                        {subCategory.map((e: any) => (
                            <Chip variant="outlined" size="small" label={e.name} className={classes.chip} />
                        ))}
                    </div>
                </CardContent>
            </CardActionArea>
        </Card>
    );
};
