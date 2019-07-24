import React from 'react';
import { usePopupState, bindTrigger, bindMenu } from 'material-ui-popup-state/hooks';
import { Link as RouterLink } from 'react-router-dom';
import useReactRouter from 'use-react-router';
import { ProductObject } from '../../types';
import lipton from '../../images/lipton.jpg';

import MoreVertIcon from '@material-ui/icons/MoreVert';
import {
    Card,
    Link,
    Avatar,
    Typography,
    CardContent,
    CardActionArea,
    makeStyles,
    Chip,
    Grid,
    IconButton,
    Menu,
    MenuItem,
} from '@material-ui/core';

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

export const ProductCard: React.FC<ProductObject> = ({ product, showMenu }) => {
    const classes = useStyles();
    const { history } = useReactRouter();
    const menuState = usePopupState({ variant: 'popover', popupId: 'CheckInMenu' });
    const { id, name, producer, category, subCategory } = product;

    const menu = (
        <div>
            <Menu {...bindMenu(menuState)}>
                <MenuItem
                    onClick={() => {
                        menuState.close();
                    }}
                >
                    Edit Product
                </MenuItem>
                <MenuItem
                    onClick={() => {
                        menuState.close();
                    }}
                >
                    Remove Product
                </MenuItem>
            </Menu>
        </div>
    );

    return (
        <CardActionArea onClick={() => history.push(`/product/${id}`)} className={classes.actionArea}>
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
                                {producer}
                            </Typography>
                            {category.map((e: any) => (
                                <Chip label={e.name} className={classes.chip} color="inherit" />
                            ))}
                            <Grid item>
                                {subCategory.map((e: any) => (
                                    <Chip variant="outlined" size="small" label={e.name} className={classes.chip} />
                                ))}
                            </Grid>
                        </Grid>
                    </Grid>
                    {showMenu && (
                        <Grid>
                            <IconButton aria-label="Settings" {...bindTrigger(menuState)}>
                                <MoreVertIcon />
                            </IconButton>
                        </Grid>
                    )}
                </Grid>
            </Grid>
            {menu}
        </CardActionArea>
    );
};

{
    /* <CardActionArea onClick={() => history.push(`/product/${id}`)} className={classes.actionArea}>
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
<IconButton aria-label="Settings" {...bindTrigger(menuState)}>
    <MoreVertIcon />
</IconButton>
</CardActionArea>
{menu} */
}
