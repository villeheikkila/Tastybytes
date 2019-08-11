import { useMutation, useQuery } from '@apollo/react-hooks';
import Typography from '@material-ui/core/Typography';
import MaterialTable from 'material-table';
import React from 'react';
import { BoxImage } from '../../components/BoxImage';
import { ALL_PRODUCTS, DELETE_PRODUCT, UPDATE_PRODUCT } from '../../graphql';

interface UpdatedProductObject {
    id: string;
    name: string;
    company: string;
    category: string;
    subCategory: [string];
}

export const ProductManagement = (): JSX.Element | null => {
    const { data, client } = useQuery(ALL_PRODUCTS);
    const { products } = data;

    const [deleteProduct] = useMutation(DELETE_PRODUCT, {
        onError: error => {
            client.writeData({
                data: {
                    notification: error.message,
                    variant: 'error',
                },
            });
        },
        refetchQueries: [{ query: ALL_PRODUCTS }],
    });

    const [updateProduct] = useMutation(UPDATE_PRODUCT, {
        onError: error => {
            client.writeData({
                data: {
                    notification: error.message,
                    variant: 'error',
                },
            });
        },
        refetchQueries: [{ query: ALL_PRODUCTS }],
    });

    if (products === undefined) {
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

    if (data.products === undefined) {
        return null;
    }

    const handleDeleteProduct = async (id: string): Promise<void> => {
        const result = await deleteProduct({
            variables: { id },
        });

        if (result) {
            client.writeData({
                data: {
                    notification: `Product ${result.data.deleteProduct.name} succesfully deleted`,
                    variant: 'success',
                },
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
            client.writeData({
                data: {
                    notification: `Product ${result.data.updateProduct.name} succesfully updated`,
                    variant: 'success',
                },
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
