import { Avatar, CardActionArea, Chip, Grid, Link, makeStyles, Typography } from '@material-ui/core';
import MoreVertIcon from '@material-ui/icons/MoreVert';
import { bindTrigger, usePopupState } from 'material-ui-popup-state/hooks';
import React, { useState } from 'react';
import { Link as RouterLink } from 'react-router-dom';
import useReactRouter from 'use-react-router';
import lipton from '../../images/lipton.jpg';
import { ProductCardMenu } from './ProductCardMenu';
import { UpdateProduct } from './UpdateProduct';

const useStyles = makeStyles(theme => ({
    actionArea: {
        padding: theme.spacing(1, 1),
    },
    picture: {
        width: 100,
        height: 100,
    },
    chips: {
        display: 'flex',
        flexDirection: 'row',
    },
    chip: {
        margin: theme.spacing(0.3),
    },
}));

interface ProductCardProps {
    product: ProductObject;
    showMenu: boolean;
}

export const ProductCard = ({ product, showMenu }: ProductCardProps): JSX.Element => {
    const classes = useStyles();
    const [showEditProduct, setShowEditProduct] = useState();
    const { history } = useReactRouter();
    const menuState = usePopupState({ variant: 'popover', popupId: 'CheckInMenu' });

    const { id, name, company, category, subCategory } = product;

    return (
        <>
            <CardActionArea onClick={(): void => history.push(`/product/${id}`)} className={classes.actionArea}>
                <Grid container spacing={3} direction="row">
                    <Grid item>
                        <Avatar alt="Image" src={lipton} className={classes.picture} />
                    </Grid>
                    <Grid item xs container>
                        <Grid item xs container direction="column">
                            <Grid item>
                                <Typography gutterBottom variant="h4">
                                    <Link component={RouterLink} to={`/product/${id}`}>
                                        {name}
                                    </Link>
                                </Typography>
                                <Typography variant="h5" gutterBottom>
                                    {company[0].name}
                                </Typography>
                                {category.map(
                                    (CategoryItem: NameId): JSX.Element => (
                                        <Chip
                                            label={CategoryItem.name}
                                            key={CategoryItem.name}
                                            className={classes.chip}
                                            color="default"
                                        />
                                    ),
                                )}
                                <Grid item>
                                    {subCategory.map(
                                        (subCategoryItem: NameId): JSX.Element => (
                                            <Chip
                                                variant="outlined"
                                                size="small"
                                                color="default"
                                                label={subCategoryItem.name}
                                                key={subCategoryItem.name}
                                                className={classes.chip}
                                            />
                                        ),
                                    )}
                                </Grid>
                            </Grid>
                        </Grid>
                        {showMenu && (
                            <Grid>
                                <MoreVertIcon {...bindTrigger(menuState)} />
                                <ProductCardMenu
                                    id={product.id}
                                    name={product.name}
                                    menuState={menuState}
                                    setShowEditProduct={setShowEditProduct}
                                />
                            </Grid>
                        )}
                    </Grid>
                </Grid>
            </CardActionArea>
            {showEditProduct && <UpdateProduct product={product} />}
        </>
    );
};
