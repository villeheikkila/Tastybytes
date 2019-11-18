import { Paper, Theme, Typography } from '@material-ui/core';
import { makeStyles } from '@material-ui/styles';
import React from 'react';
import { CategoryManagement } from './CategoryManagement';
import { ProductManagement } from './ProductManagement';
import { UserManagement } from './UserManagement';

const useStyles = makeStyles((theme: Theme) => ({
    paper: {
        padding: theme.spacing(3, 2),
        maxWidth: 800,
        margin: `${theme.spacing(1)}px auto`,
        display: 'flex',
        flexDirection: 'column',
    },
    table: {
        maxWidth: 800,
        margin: `${theme.spacing(1)}px auto`,
    },
}));

export const Dashboard = (): JSX.Element | null => {
    const classes = useStyles({});

    return (
        <>
            <Paper className={classes.paper}>
                <Typography component="h1" variant="h5">
                    Admin dashboard
                </Typography>
            </Paper>
            <div className={classes.table}>
                <CategoryManagement />
            </div>
            <div className={classes.table}>
                <UserManagement />
            </div>
            <div className={classes.table}>
                <ProductManagement />
            </div>
        </>
    );
};
