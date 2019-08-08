import { useMutation, useQuery } from '@apollo/react-hooks';
import { Button, Divider, List, ListSubheader, TextField, Theme, Typography } from '@material-ui/core';
import { makeStyles } from '@material-ui/styles';
import React, { useState } from 'react';
import { ALL_CATEGORIES, CREATE_CATEGORY } from '../../graphql/product';
import { errorHandler, notificationHandler } from '../../utils';

const useStyles = makeStyles((theme: Theme) => ({
    button: {
        margin: theme.spacing(1),
    },
    textField: {
        marginTop: 15,
        width: '100%',
    },
    list: {
        width: '100%',
        backgroundColor: theme.palette.background.paper,
    },
}));

export const CategoryManagement = (): JSX.Element | null => {
    const classes = useStyles('');

    const [name, setName] = useState();
    const categoriesQuery = useQuery(ALL_CATEGORIES);

    const [createCategory] = useMutation(CREATE_CATEGORY, {
        onError: errorHandler,
        refetchQueries: [{ query: ALL_CATEGORIES }],
    });

    if (categoriesQuery.data.categories === undefined) return null;

    const categories = categoriesQuery.data.categories;

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
        <>
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
            <List
                className={classes.list}
                aria-labelledby="nested-list-subheader"
                subheader={<ListSubheader component="div">Pending Friend Requests</ListSubheader>}
            >
                {categories.map(
                    (category: Category): JSX.Element => (
                        <div key={category.id.toUpperCase()}>
                            <Divider light />
                            <p>{category.name}</p>
                            <Divider light />
                        </div>
                    ),
                )}
            </List>
        </>
    );
};
