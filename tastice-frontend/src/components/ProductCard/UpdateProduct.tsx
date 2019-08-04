import { useMutation, useQuery } from '@apollo/react-hooks';
import { Button, CardContent, Grid, makeStyles, TextField, Typography } from '@material-ui/core';
import React, { useEffect, useState } from 'react';
import { ALL_CATEGORIES, ALL_COMPANIES, UPDATE_PRODUCT, SEARCH_CHECKINS, SEARCH_PRODUCTS } from '../../graphql';
import { errorHandler, notificationHandler } from '../../utils';
import { MaterialSelect } from '../MaterialSelect';

const useStyles = makeStyles(theme => ({
    card: {
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

interface UpdateProductProps {
    product: Product;
    onCancel: any;
}
export const UpdateProduct = ({ product, onCancel }: UpdateProductProps): JSX.Element | null => {
    const classes = useStyles();
    const [name, setName] = useState('');
    const [company, setCompany] = useState();
    const [category, setCategory] = useState();
    const [subCategory, setSubCategory] = useState();
    const categoriesQuery = useQuery(ALL_CATEGORIES);
    const companiesQuery = useQuery(ALL_COMPANIES);

    const [updateProduct] = useMutation(UPDATE_PRODUCT, {
        onError: errorHandler,
        refetchQueries: [
            { query: SEARCH_CHECKINS, variables: { filter: '' } },
            { query: SEARCH_PRODUCTS, variables: { filter: '' } },
        ],
    });

    useEffect((): void => {
        setName(product.name);
        setCompany({
            value: product.company.name,
            label: product.company.name,
            id: product.company.id,
        });
        setCategory({
            value: product.category[0].name,
            label: product.category[0].name,
            id: product.category[0].id,
        });
        const oldSubCategories = product.subCategory.map((subCategoryItem: NameId) => ({
            value: subCategoryItem.name,
            label: subCategoryItem.name,
            id: subCategoryItem.id,
        }));
        setSubCategory(oldSubCategories);
    }, [product.name, product.company, product.category, product.subCategory]);

    if (categoriesQuery === null || categoriesQuery.data.categories === undefined) {
        return null;
    }

    const categories = categoriesQuery.data.categories;
    const companies = companiesQuery.data.companies;

    const handleNameChange = (event: React.ChangeEvent<HTMLInputElement>): void => setName(event.target.value);

    const handleCompanyChange = (value: Suggestions): void => setCompany(value);

    const handleCategoryChange = (value: Suggestions): void => setCategory(value);

    const handleSubCategoryChange = (value: Suggestions): void => setSubCategory(value);

    const handleUpdateProduct = async (event: React.FormEvent<HTMLFormElement>): Promise<void> => {
        event.preventDefault();

        if (name.length < 3) {
            notificationHandler({
                message: `Product name must have at least three letters`,
                variant: 'error',
            });
            return;
        }

        if (company.value.length < 3) {
            notificationHandler({
                message: `Company name must have at least three letters`,
                variant: 'error',
            });
            return;
        }

        if (!category) {
            notificationHandler({
                message: `Please select a category`,
                variant: 'error',
            });
            return;
        }

        const subCategoryArray = subCategory
            ? subCategory.map((subCategoryItem: Suggestions): string => subCategoryItem.value)
            : [];

        const result = await updateProduct({
            variables: {
                id: product.id,
                name,
                company: company.value,
                categoryId: category.id,
                subCategories: subCategoryArray,
            },
        });

        if (result) {
            notificationHandler({
                message: `Product ${result.data.updateProduct.name} succesfully updated`,
                variant: 'success',
            });
        }
    };

    const categorySuggestions = categories.map(
        (suggestion: NameId): Suggestions => ({
            value: suggestion.name,
            label: suggestion.name,
            id: suggestion.id,
        }),
    );

    const companySuggestions = companies.map(
        (suggestion: NameId): Suggestions => ({
            value: suggestion.name,
            label: suggestion.name,
            id: suggestion.id,
        }),
    );

    const selected = category && category.value;

    const subCategoriesSelected = categories.filter(
        (categoryObject: Category): boolean => categoryObject.name === selected,
    );

    const subCategoriesSuggestions =
        subCategoriesSelected.length > 0 &&
        subCategoriesSelected[0].subCategory.map(
            (suggestion: NameId): Suggestions => ({
                value: suggestion.name,
                label: suggestion.name,
                id: suggestion.id,
            }),
        );

    return (
        <div className={classes.root}>
            <CardContent className={classes.card}>
                <Typography component="h1" variant="h5">
                    Edit Product
                </Typography>

                <form onSubmit={handleUpdateProduct}>
                    <TextField
                        id="Name"
                        label="Name"
                        name="Name"
                        placeholder="Name of the product"
                        value={name}
                        onChange={handleNameChange}
                        className={classes.textField}
                    />
                    <Grid container alignContent={'center'} alignItems={'center'} spacing={2}>
                        <Grid item xs={12} sm={6} />
                        <Grid item xs={12}>
                            <MaterialSelect
                                isCreatable={true}
                                isMulti={false}
                                suggestions={companySuggestions}
                                label={'Company'}
                                placeholder={'Select a company'}
                                onChange={handleCompanyChange}
                                value={company}
                            />
                            <MaterialSelect
                                isCreatable={false}
                                isMulti={false}
                                suggestions={categorySuggestions}
                                label={'Category'}
                                placeholder={'Select a category'}
                                onChange={handleCategoryChange}
                                value={category}
                            />
                            <MaterialSelect
                                isCreatable={true}
                                isMulti={true}
                                suggestions={subCategoriesSuggestions}
                                label={'Subcategory'}
                                placeholder={'Select a subcategory or a create a new one'}
                                onChange={handleSubCategoryChange}
                                value={subCategory}
                            />
                        </Grid>
                        <Grid item xs={12}>
                            <Button type="submit" variant="contained" color="primary" className={classes.button}>
                                Update Product!
                            </Button>
                            <Button variant="contained" color="secondary" className={classes.button} onClick={onCancel}>
                                Cancel
                            </Button>
                        </Grid>
                    </Grid>
                </form>
            </CardContent>
        </div>
    );
};
