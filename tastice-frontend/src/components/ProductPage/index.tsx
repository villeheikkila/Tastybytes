import React from "react";
import { useQuery } from "@apollo/react-hooks";
import { PRODUCT, ME } from "../../queries";
import { ProductCard } from "../ProductCard";
import { Divider } from "../Divider";
import { CheckInCard } from "../CheckInCard";
import { CreateCheckIn } from "../CreateCheckIn";

export const ProductPage: React.FC<any> = id => {
  const me = useQuery(ME);
  const productsQuery = useQuery(PRODUCT, {
    variables: { id: id.id }
  });

  if (
    productsQuery.data === undefined ||
    productsQuery.data.product === undefined
  ) {
    return null;
  }

  const product = productsQuery.data.product[0];

  const productObject = {
    id: product.id,
    name: product.name,
    producer: product.producer,
    category: product.category,
    subCategory: product.subCategory
  };

  const dividerText =
    product.checkins.length === 0 ? "No Recent Activity" : "Recent Activity";

  return (
    <>
      <ProductCard product={productObject} />
      <CreateCheckIn authorId={me.data.me.id} productId={product.id} />
      <Divider text={dividerText} />

      {product.checkins.map((checkin: any) => (
        <CheckInCard key={checkin.createdAt} checkin={checkin} />
      ))}
    </>
  );
};
