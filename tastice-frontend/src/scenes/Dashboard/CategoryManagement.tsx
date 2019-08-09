import { useMutation, useQuery } from '@apollo/react-hooks';
import MaterialTable from 'material-table';
import React from 'react';
import { ALL_CATEGORIES, CREATE_CATEGORY, DELETE_CATEGORY, UPDATE_CATEGORY } from '../../graphql/product';
import { errorHandler, notificationHandler } from '../../utils';

export const CategoryManagement = (): JSX.Element | null => {
    const { data } = useQuery(ALL_CATEGORIES);
    const { categories } = data;

    const [createCategory] = useMutation(CREATE_CATEGORY, {
        onError: errorHandler,
        refetchQueries: [{ query: ALL_CATEGORIES }],
    });

    const [deleteCategory] = useMutation(DELETE_CATEGORY, {
        onError: errorHandler,
        refetchQueries: [{ query: ALL_CATEGORIES }],
    });

    const [updateCategory] = useMutation(UPDATE_CATEGORY, {
        onError: errorHandler,
        refetchQueries: [{ query: ALL_CATEGORIES }],
    });

    if (categories === undefined) return null;

    const handleCreateCategory = async ({ name }: any): Promise<void> => {
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

    const handleDeleteCategory = async ({ id }: any): Promise<void> => {
        const result = await deleteCategory({
            variables: { id },
        });

        if (result) {
            notificationHandler({
                message: `Category ${result.data.deleteCategory.name} succesfully deleted`,
                variant: 'success',
            });
        }
    };

    const handleUpdateCategory = async ({ name, id }: any): Promise<void> => {
        const result = await updateCategory({
            variables: { id, name },
        });

        if (result) {
            notificationHandler({
                message: `Category ${name} succesfully renamed to ${result.data.updateCategory.name}`,
                variant: 'success',
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
