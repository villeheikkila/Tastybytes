import React, { useState } from "react";
import { useQuery, useMutation } from "@apollo/react-hooks";
import { PRODUCT } from "../../queries";
import { ProductCard } from "../ProductCard";

export const CreateCheckIn: React.FC<any> = id => {
  console.log("id: ", id.id);
  const productsQuery = useQuery(PRODUCT, {
    variables: { id: id.id }
  });

  if (productsQuery.data === undefined) {
    return null;
  }
  const product = productsQuery.data.product[0];
  console.log("product: ", product[0]);

  const producta = {
    id,
    name: product.name,
    producer: product.producer,
    category: product.type,
    subCategory: product.type
  };

  return (
    <div>
      <ProductCard product={producta} show={false} />
    </div>
  );
};
