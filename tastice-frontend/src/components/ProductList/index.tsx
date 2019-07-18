import React from "react";
import { ALL_PRODUCTS, UPDATE_PRODUCT, DELETE_PRODUCT } from "../../queries";
import { useQuery, useMutation } from "@apollo/react-hooks";
import MaterialTable from "material-table";
import { notificationHandler, errorHandler } from "../../utils";

export const ProductList = () => {
  const productsQuery = useQuery(ALL_PRODUCTS);
  const products = productsQuery.data.products;
  const productsObject = products.map((e: any) => ({
    name: products.name,
    producer: products.producer,
    id: products.id
  }));
  const [deleteProduct] = useMutation(DELETE_PRODUCT, {
    onError: errorHandler,
    refetchQueries: [{ query: ALL_PRODUCTS }]
  });

  const [updateProduct] = useMutation(UPDATE_PRODUCT, {
    onError: errorHandler,
    refetchQueries: [{ query: ALL_PRODUCTS }]
  });

  if (productsQuery.data.products === undefined) {
    return null;
  }

  const handleDeleteProduct = async (id: any) => {
    const result = await deleteProduct({
      variables: { id }
    });

    if (result) {
      notificationHandler({
        message: `Product ${
          result.data.deleteProduct.name
        } succesfully deleted`,
        variant: "success"
      });
    }
  };

  const handleUpdateProduct = async (product: any) => {
    const result = await updateProduct({
      variables: {
        id: product.id,
        name: product.name,
        producer: product.producer,
        type: product.type
      }
    });

    if (result) {
      console.log("result: ", result);
    }
  };

  return (
    <MaterialTable
      title="List of all products"
      columns={[
        { title: "Name", field: "name" },
        { title: "Producer", field: "producer" },
        { title: "ID", field: "id" }
      ]}
      data={productsObject}
      editable={{
        onRowUpdate: (updatedProduct, oldProduct) =>
          new Promise(resolve => {
            setTimeout(() => {
              resolve();
              handleUpdateProduct(updatedProduct);
            }, 600);
          }),
        onRowDelete: oldProduct =>
          new Promise(resolve => {
            setTimeout(() => {
              resolve();
              handleDeleteProduct(oldProduct.id);
            }, 100);
          })
      }}
    />
  );
};
