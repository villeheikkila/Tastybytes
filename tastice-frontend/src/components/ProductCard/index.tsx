import { CardActionArea, Chip, Grid, Link, makeStyles, Theme, Typography } from '@material-ui/core';
import MoreVertIcon from '@material-ui/icons/MoreVert';
import { bindTrigger, usePopupState } from 'material-ui-popup-state/hooks';
import React, { useState } from 'react';
import { Link as RouterLink } from 'react-router-dom';
import useReactRouter from 'use-react-router';
import { BoxImage } from '../BoxImage';
import { ProductCardMenu } from './ProductCardMenu';
import { UpdateProduct } from './UpdateProduct';

const useStyles = makeStyles((theme: Theme) => ({
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
    product: Product;
    showMenu: boolean;
}

export const ProductCard = ({ product, showMenu }: ProductCardProps): JSX.Element => {
    const classes = useStyles({});
    const [showEditProduct, setShowEditProduct] = useState();
    const { history } = useReactRouter();
    const menuState = usePopupState({ variant: 'popover', popupId: 'CheckInMenu' });

    return (
        <>
            <CardActionArea onClick={(): void => history.push(`/product/${product.id}`)} className={classes.actionArea}>
                <Grid container spacing={3} direction="row">
                    <Grid item>
                        <BoxImage
                            image={product.imageId}
                            text={product.category[0].name}
                            color={product.category[0].color}
                        />
                    </Grid>
                    <Grid item xs container>
                        <Grid item xs container direction="column">
                            <Grid item>
                                <Typography gutterBottom variant="h4">
                                    <Link component={RouterLink} to={`/product/${product.id}`}>
                                        {product.name}
                                    </Link>
                                </Typography>
                                <Typography variant="h5" gutterBottom>
                                    {product.company.name}
                                </Typography>
                                {product.category.map(
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
                                    {product.subCategory.map(
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
            {showEditProduct && <UpdateProduct product={product} onCancel={() => setShowEditProduct(false)} />}
        </>
    );
};
