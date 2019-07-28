import React, { useState, useEffect } from 'react';
import { useMutation, useQuery } from '@apollo/react-hooks';
import { notificationHandler, errorHandler } from '../../utils';
import { MaterialSelect } from '../MaterialSelect';
import { ALL_PRODUCTS, ALL_CATEGORIES, ALL_COMPANIES, UPDATE_PRODUCT } from '../../queries';
import { Typography, Grid, Button, TextField, makeStyles, CardContent } from '@material-ui/core';

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

export const UpdateProduct: React.FC<any> = ({ product }) => {
    const classes = useStyles();
    const [name, setName] = useState('');
    const [company, setCompany] = useState();
    const [category, setCategory] = useState();
    const [subCategory, setSubCategory] = useState();
    const categories = useQuery(ALL_CATEGORIES);
    const companies = useQuery(ALL_COMPANIES);

    const [updateProduct] = useMutation(UPDATE_PRODUCT, {
        onError: errorHandler,
        refetchQueries: [{ query: ALL_PRODUCTS }],
    });

    useEffect(() => {
        setName(product.name);
        setCompany(product.company);
        setCategory(product.category[0].name);
        setSubCategory(product.subCategory[0].name);
    }, [product.name, product.company, product.category, product.subCategory]);

    if (categories === null || categories.data.categories === undefined) {
        return null;
    }

    const handleNameChange = (event: any) => setName(event.target.value);

    const handleCompanyChange = (value: any) => setCompany(value);

    const handleCategoryChange = (value: any) => setCategory(value);

    const handleSubCategoryChange = (value: any) => setSubCategory(value);

    const handleAddProduct = async (event: any) => {
        event.preventDefault();

        const subCategoryArray = subCategory.map((e: any) => {
            return e.value;
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

    const categorySuggestions = categories.data.categories.map((suggestion: any) => ({
        value: suggestion.name,
        label: suggestion.name,
        id: suggestion.id,
    }));

    const companySuggestions = companies.data.companies.map((suggestion: any) => ({
        value: suggestion.name,
        label: suggestion.name,
        id: suggestion.id,
    }));

    const selected = category && category.value;

    const subCategoriesSelected = categories.data.categories.filter((x: any) => x.name === selected);

    const subCategoriesSuggestions =
        subCategoriesSelected.length > 0 &&
        subCategoriesSelected[0].subCategory.map((suggestion: any) => ({
            value: suggestion.name,
            label: suggestion.name,
            id: suggestion.id,
        }));

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
