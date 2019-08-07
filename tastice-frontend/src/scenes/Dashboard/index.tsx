import { useMutation } from '@apollo/react-hooks';
import { Button, Paper, TextField, Theme, Typography } from '@material-ui/core';
import { makeStyles } from '@material-ui/styles';
import React, { useState } from 'react';
import { ALL_CATEGORIES, CREATE_CATEGORY } from '../../graphql/product';
import { errorHandler, notificationHandler } from '../../utils';

const useStyles = makeStyles((theme: Theme) => ({
    paper: {
        padding: theme.spacing(3, 2),
        maxWidth: 700,
        margin: `${theme.spacing(1)}px auto`,
        display: 'flex',
        flexDirection: 'column',
    },
    button: {
        margin: theme.spacing(1),
    },
    root: {
        paddingTop: 30,
    },
    textField: {
        marginTop: 15,
        width: '100%',
    },
}));

export const Dashboard = (): JSX.Element | null => {
    const classes = useStyles('');

    const [name, setName] = useState();
    const [createCategory] = useMutation(CREATE_CATEGORY, {
        onError: errorHandler,
        refetchQueries: [{ query: ALL_CATEGORIES }],
    });

    const handleCreateCategory = async (event: any): Promise<void> => {
        event.preventDefault();
        const result = await createCategory({
            variables: {
                name,
            },
        });

        if (result) {
            notificationHandler({
                message: `A new '${result.data.createCategory.name}' category created!`,
                variant: 'success',
            });
        }
    };

    return (
        <div className={classes.root}>
            <Paper className={classes.paper}>
                <Typography component="h1" variant="h5">
                    Admin dashboard
                </Typography>
            </Paper>

            <Paper className={classes.paper}>
                <Typography component="h1" variant="h5">
                    Add a new category!
                </Typography>
                <form onSubmit={handleCreateCategory}>
                    <TextField
                        id="Name"
                        label="Name"
                        name="Name"
                        placeholder="Name of the product"
                        onChange={({ target }): void => setName(target.value)}
                        value={name}
                        className={classes.textField}
                    />
                    <Button type="submit" variant="contained" color="primary" className={classes.button}>
                        Add
                    </Button>
                </form>
            </Paper>
        </div>
    );
};
