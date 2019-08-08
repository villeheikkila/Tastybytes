import { useMutation, useQuery } from '@apollo/react-hooks';
import Typography from '@material-ui/core/Typography';
import MaterialTable from 'material-table';
import React from 'react';
import { BoxImage } from '../../components/BoxImage';
import { ALL_PRODUCTS, DELETE_PRODUCT, UPDATE_PRODUCT } from '../../graphql';
import { errorHandler, notificationHandler } from '../../utils';

interface UpdatedProductObject {
    id: string;
    name: string;
    company: string;
    category: string;
    subCategory: [string];
}

export const ProductManagement = (): JSX.Element | null => {
    const productsQuery = useQuery(ALL_PRODUCTS);
    const products = productsQuery.data.products;

    const [deleteProduct] = useMutation(DELETE_PRODUCT, {
        onError: errorHandler,
        refetchQueries: [{ query: ALL_PRODUCTS }],
    });

    const [updateProduct] = useMutation(UPDATE_PRODUCT, {
        onError: errorHandler,
        refetchQueries: [{ query: ALL_PRODUCTS }],
    });

    if (productsQuery.data.products === undefined) {
        return null;
    }

    const productsObjects = products.map((product: Product) => ({
        id: product.id,
        name: product.name,
        company: product.company,
        category: product.category[0],
        subCategory: product.subCategory,
        imageId: product.imageId,
        color: product.category[0].color,
    }));

    if (productsQuery.data.products === undefined) {
        return null;
    }

    const handleDeleteProduct = async (id: string): Promise<void> => {
        const result = await deleteProduct({
            variables: { id },
        });

        if (result) {
            notificationHandler({
                message: `Product ${result.data.deleteProduct.name} succesfully deleted`,
                variant: 'success',
            });
        }
    };

    const handleUpdateProduct = async ({ id, name, company, category, subCategory }: any): Promise<void> => {
        const subCategoryArray = subCategory.map((subCategoryUnit: any): string => {
            return subCategoryUnit.name;
        });

        const result = await updateProduct({
            variables: {
                id,
                name,
                company: company.name,
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

    return (
        <MaterialTable
            title="Products"
            columns={[
                { title: 'Name', field: 'name' },
                { title: 'Company', field: 'company.name' },
                { title: 'Category', field: 'category.name' },
            ]}
            data={productsObjects}
            editable={{
                onRowUpdate: updatedProduct =>
                    new Promise(resolve => {
                        setTimeout((): void => {
                            resolve();
                            handleUpdateProduct(updatedProduct);
                        }, 600);
                    }),
                onRowDelete: deleteProduct =>
                    new Promise(resolve => {
                        setTimeout((): void => {
                            resolve();
                            handleDeleteProduct(deleteProduct.id);
                        }, 100);
                    }),
            }}
            options={{ exportButton: true }}
            detailPanel={rowData => {
                return (
                    <>
                        <Typography>Avatar</Typography>
                        <BoxImage image={rowData.imageId} text={rowData.category.name} color={rowData.color} />
                    </>
                );
            }}
        />
    );
};
