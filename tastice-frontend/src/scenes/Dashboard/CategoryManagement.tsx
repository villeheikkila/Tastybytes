import { useMutation, useQuery } from '@apollo/react-hooks';
import MaterialTable from 'material-table';
import React from 'react';
import { Loading } from '../../components/Loading';
import { ALL_CATEGORIES, CREATE_CATEGORY, DELETE_CATEGORY, UPDATE_CATEGORY } from '../../graphql/product';

export const CategoryManagement = (): JSX.Element => {
    const { loading, data, client } = useQuery(ALL_CATEGORIES);

    const [createCategory] = useMutation(CREATE_CATEGORY, {
        onError: error => {
            client.writeData({
                data: {
                    notification: error.message,
                    variant: 'error',
                },
            });
        },
        refetchQueries: [{ query: ALL_CATEGORIES }],
    });

    const [deleteCategory] = useMutation(DELETE_CATEGORY, {
        onError: error => {
            client.writeData({
                data: {
                    notification: error.message,
                    variant: 'error',
                },
            });
        },
        refetchQueries: [{ query: ALL_CATEGORIES }],
    });

    const [updateCategory] = useMutation(UPDATE_CATEGORY, {
        onError: error => {
            client.writeData({
                data: {
                    notification: error.message,
                    variant: 'error',
                },
            });
        },
        refetchQueries: [{ query: ALL_CATEGORIES }],
    });

    if (loading) return <Loading />;

    const { categories } = data;

    const handleCreateCategory = async ({ name }: any): Promise<void> => {
        const result = await createCategory({
            variables: {
                name,
            },
        });

        if (result) {
            client.writeData({
                data: {
                    notification: `A new '${result.data.createCategory.name}' category created!`,
                    variant: 'success',
                },
            });
        }
    };

    const handleDeleteCategory = async ({ id }: any): Promise<void> => {
        const result = await deleteCategory({
            variables: { id },
        });

        if (result) {
            client.writeData({
                data: {
                    notification: `Category ${result.data.deleteCategory.name} succesfully deleted`,
                    variant: 'success',
                },
            });
        }
    };

    const handleUpdateCategory = async ({ name, id }: any): Promise<void> => {
        const result = await updateCategory({
            variables: { id, name },
        });

        if (result) {
            client.writeData({
                data: {
                    notification: `Category ${name} succesfully renamed to ${result.data.updateCategory.name}`,
                    variant: 'success',
                },
            });
        }
    };

    return (
        <MaterialTable
            title="Categories"
            columns={[{ title: 'Name', field: 'name' }]}
            data={categories}
            editable={{
                onRowAdd: newCategory =>
                    new Promise(resolve => {
                        setTimeout(() => {
                            resolve();
                            handleCreateCategory(newCategory);
                        }, 600);
                    }),
                onRowUpdate: updatedProduct =>
                    new Promise(resolve => {
                        setTimeout((): void => {
                            resolve();
                            handleUpdateCategory(updatedProduct);
                        }, 600);
                    }),
                onRowDelete: deleteProduct =>
                    new Promise(resolve => {
                        setTimeout((): void => {
                            resolve();
                            handleDeleteCategory(deleteProduct);
                        }, 100);
                    }),
            }}
            options={{ exportButton: true }}
        />
    );
};
