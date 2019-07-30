import { useMutation } from '@apollo/react-hooks';
import { Avatar, CardActionArea, Chip, Grid, Link, makeStyles, Menu, MenuItem, Typography } from '@material-ui/core';
import MoreVertIcon from '@material-ui/icons/MoreVert';
import { bindMenu, bindTrigger, usePopupState } from 'material-ui-popup-state/hooks';
import React, { useState } from 'react';
import { Link as RouterLink } from 'react-router-dom';
import useReactRouter from 'use-react-router';
import lipton from '../../images/lipton.jpg';
import { ALL_PRODUCTS, DELETE_PRODUCT } from '../../queries';
import { errorHandler, notificationHandler } from '../../utils';
import { ConfirmationDialog } from '../ConfirmationDialog';
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
    const [visible, setVisible] = useState(false);
    const [showEditProduct, setShowEditProduct] = useState();
    const { history } = useReactRouter();
    const menuState = usePopupState({ variant: 'popover', popupId: 'CheckInMenu' });
    const [deleteProduct] = useMutation(DELETE_PRODUCT, {
        onError: errorHandler,
        refetchQueries: [{ query: ALL_PRODUCTS }],
    });

    const { id, name, company, category, subCategory } = product;

    const handleDeleteProduct = async (): Promise<void> => {
        setVisible(false);
        const result = await deleteProduct({
            variables: { id: product.id },
        });

        if (result) {
            notificationHandler({
                message: `Product ${result.data.deleteProduct.name} succesfully deleted`,
                variant: 'success',
            });
            history.push(`/activity`);
        }
    };

    const menu = (
        <div>
            <Menu {...bindMenu(menuState)}>
                <MenuItem
                    onClick={(): void => {
                        menuState.close();
                        setShowEditProduct(true);
                    }}
                >
                    Edit Product
                </MenuItem>
                <MenuItem
                    onClick={(): void => {
                        menuState.close();
                        setVisible(true);
                    }}
                >
                    Remove Product
                </MenuItem>
            </Menu>

            <ConfirmationDialog
                visible={visible}
                setVisible={setVisible}
                description={'HEEII'}
                title={'Warning!'}
                content={`Are you sure you want to remove ${product.name}`}
                onAccept={handleDeleteProduct}
                declineButton={'Cancel'}
                acceptButton={'Yes'}
            />
        </div>
    );

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
                                {menu}
                            </Grid>
                        )}
                    </Grid>
                </Grid>
            </CardActionArea>
            {showEditProduct && <UpdateProduct product={product} />}
        </>
    );
};
