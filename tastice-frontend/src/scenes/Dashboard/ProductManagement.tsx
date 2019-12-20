import { useMutation, useQuery } from '@apollo/react-hooks';
import Typography from '@material-ui/core/Typography';
import MaterialTable from 'material-table';
import React from 'react';
import { BoxImage } from '../../components/BoxImage';
import { Loading } from '../../components/Loading';
import { ALL_PRODUCTS, DELETE_PRODUCT, UPDATE_PRODUCT } from '../../graphql';

interface UpdatedProductObject {
    id: string;
    name: string;
    company: string;
    category: string;
    subCategory: [string];
}

export const ProductManagement = (): JSX.Element => {
    const { loading, data, client } = useQuery(ALL_PRODUCTS);

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

    if (loading) return <Loading />;

    const { products } = data;

    const productsObject: any = products.map((product: Product) => ({
        id: product.id,
        name: product.name,
        company: product.company,
        category: product.category[0],
        subCategory: product.subCategory,
        imageId: product.imageId,
        color: product.category[0].color,
    }));

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
                { title: 'id', field: 'category.id' },
            ]}
            data={productsObject as any}
            editable={{
                onRowUpdate: updatedProduct =>
                    new Promise(resolve => {
                        setTimeout((): void => {
                            resolve();
                            handleUpdateProduct(updatedProduct);
                        }, 600);
                    }),
                onRowDelete: (deleteProduct: any) =>
                    new Promise(resolve => {
                        setTimeout((): void => {
                            resolve();
                            handleDeleteProduct(deleteProduct.id);
                        }, 100);
                    }),
            }}
            options={{ exportButton: true }}
            detailPanel={(rowData: any) => {
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
