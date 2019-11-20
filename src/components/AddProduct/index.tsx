import { useApolloClient, useMutation, useQuery } from '@apollo/react-hooks';
import { Button, Grid, makeStyles, Paper, TextField, Typography } from '@material-ui/core';
import React, { useState } from 'react';
import useReactRouter from 'use-react-router';
import { Loading } from '../../components/Loading';
import { ADD_PRODUCT, ALL_CATEGORIES, ALL_COMPANIES, SEARCH_PRODUCTS } from '../../graphql';
import { ImageUpload } from '../ImageUpload';
import { MaterialSelect } from '../MaterialSelect';

const useStyles = makeStyles(theme => ({
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

export const AddProduct = (): JSX.Element | null => {
    const classes = useStyles({});
    const [image, setImage] = useState();
    const [name, setName] = useState('');
    const [company, setCompany] = useState();
    const [category, setCategory] = useState();
    const [subCategory, setSubCategory] = useState();
    const { history } = useReactRouter();
    const client = useApolloClient();

    const { data: categoriesData } = useQuery(ALL_CATEGORIES);
    const { data: companiesData } = useQuery(ALL_COMPANIES);

    const [addProduct] = useMutation(ADD_PRODUCT, {
        onError: (error: any) => {
            client.writeData({
                data: {
                    notification: error.message,
                    variant: 'error',
                },
            });
        },
        refetchQueries: [
            { query: SEARCH_PRODUCTS, variables: { filter: '', first: 5 } },
            { query: ALL_CATEGORIES },
            { query: ALL_COMPANIES },
        ],
    });

    if (!categoriesData || !companiesData || !categoriesData.categories || !companiesData.companies) return <Loading />;

    const { categories } = categoriesData;
    const { companies } = companiesData;

    const handleNameChange = (event: React.ChangeEvent<HTMLInputElement>): void => setName(event.target.value);

    const handleCompanyChange = (value: Suggestions): void => setCompany(value);

    const handleCategoryChange = (value: Suggestions): void => setCategory(value);

    const handleSubCategoryChange = (value: Suggestions): void => setSubCategory(value);

    const handleAddProduct = async (event: React.FormEvent<HTMLFormElement>): Promise<void> => {
        event.preventDefault();

        if (name.length < 3) {
            client.writeData({
                data: {
                    notification: `Product name must have at least three letters`,
                    variant: 'error',
                },
            });
            return;
        }

        if (company.value.length < 3) {
            client.writeData({
                data: {
                    notification: `Company name must have at least three letters`,
                    variant: 'error',
                },
            });
            return;
        }

        if (!category) {
            client.writeData({
                data: {
                    notification: `Please select a category`,
                    variant: 'error',
                },
            });
            return;
        }

        const subCategoryArray = subCategory
            ? subCategory.map((subCategoryItem: Suggestions): string => subCategoryItem.value)
            : [];

        const result = await addProduct({
            variables: {
                name,
                imageId: image,
                company: company.value,
                categoryId: category.id,
                subCategories: subCategoryArray,
            },
        });

        if (result) {
            client.writeData({
                data: {
                    notification: `Product ${result.data.addProduct.name} succesfully added`,
                    variant: 'success',
                },
            });
            history.push(`/product/${result.data.addProduct.id}`);
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
            <Paper className={classes.paper}>
                <Typography component="h1" variant="h5">
                    Add a new product!
                </Typography>
                <ImageUpload image={image} setImage={setImage} />
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
                                Add Product!
                            </Button>
                        </Grid>
                    </Grid>
                </form>
            </Paper>
        </div>
    );
};
