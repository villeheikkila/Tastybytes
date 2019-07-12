import React, { useState } from "react";
import { DELETE_PRODUCT, UPDATE_PRODUCT } from "./queries";
import { useMutation } from "@apollo/react-hooks";
import { notificationHandler, errorHandler } from "../../utils";

export const Product = () => {
  const [updatedName, setUpdatedName] = useState("");
  const [updatedProducer, setUpdatedProducer] = useState("");
  const [updatedType, setUpdatedType] = useState("");

  const product = {
    id: "asdd",
    name: "asddadsd",
    producer: "dsadasd",
    type: "asdasdas"
  };

  const [deleteProduct] = useMutation(DELETE_PRODUCT, {
    onError: errorHandler
  });

  const [updateProduct] = useMutation(UPDATE_PRODUCT, {
    onError: errorHandler
  });

  if (product === undefined) {
    return null;
  }

  const handleDeleteProduct = async () => {
    console.log("id:", product.id, "id");

    const result = await deleteProduct({
      variables: { id: product.id }
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

  const handleUpdateProduct = async (
    event: React.FormEvent<HTMLFormElement>
  ): Promise<void> => {
    event.preventDefault();

    const result = await updateProduct({
      variables: {
        id: product.id,
        name: updatedName,
        producer: updatedProducer,
        type: updatedType
      }
    });

    if (result) {
      console.log("result: ", result);
    }

    setUpdatedName("");
    setUpdatedProducer("");
    setUpdatedType("");
  };

  return (
    <div>
      <p>
        name: {product.name} producer: {product.producer} type: {product.type}{" "}
      </p>
      <button onClick={handleDeleteProduct}>Delete</button>
      <form onSubmit={handleUpdateProduct}>
        <div>
          <p>New name</p>
          <input
            value={updatedName}
            onChange={({ target }) => setUpdatedName(target.value)}
          />
        </div>
        <div>
          <p>New producer</p>
          <input
            value={updatedProducer}
            onChange={({ target }) => setUpdatedProducer(target.value)}
          />
        </div>
        <div>
          <p>New type</p>
          <input
            value={updatedType}
            onChange={({ target }) => setUpdatedType(target.value)}
          />
        </div>
        <button type="submit">Update product!</button>
      </form>
    </div>
  );
};
