import { useMutation, useQuery } from '@apollo/react-hooks';
import { Button, CardContent, Grid, makeStyles, TextField, Typography } from '@material-ui/core';
import React, { useEffect, useState } from 'react';
import { ALL_CATEGORIES, ALL_COMPANIES, ALL_PRODUCTS, UPDATE_PRODUCT } from '../../queries';
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
    product: ProductObject;
}
export const UpdateProduct = ({ product }: UpdateProductProps): JSX.Element | null => {
    const classes = useStyles();
    const [name, setName] = useState('');
    const [company, setCompany] = useState();
    const [category, setCategory] = useState();
    const [subCategory, setSubCategory] = useState();
    const categoriesQuery = useQuery(ALL_CATEGORIES);
    const companiesQuery = useQuery(ALL_COMPANIES);

    const [updateProduct] = useMutation(UPDATE_PRODUCT, {
        onError: errorHandler,
        refetchQueries: [{ query: ALL_PRODUCTS }],
    });

    useEffect((): void => {
        setName(product.name);
        setCompany(product.company);
        setCategory(product.category[0].name);
        setSubCategory(product.subCategory[0].name);
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

    const handleAddProduct = async (event: React.FormEvent<HTMLFormElement>): Promise<void> => {
        event.preventDefault();

        const subCategoryArray = subCategory.map((subCategoryItem: Suggestions): string => {
            return subCategoryItem.value;
        });

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
                message: `Product ${result.data.addProduct.name} succesfully updated`,
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

                <form onSubmit={handleAddProduct}>
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
                            <Button type="submit" variant="contained" color="secondary" className={classes.button}>
                                Update Product!
                            </Button>
                        </Grid>
                    </Grid>
                </form>
            </CardContent>
        </div>
    );
};
