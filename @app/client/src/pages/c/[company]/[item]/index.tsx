import { SharedLayout } from "@app/components";
import { ProductByIdQuery, useProductByIdQuery } from "@app/graphql";
import { styled } from "@stitches/react";
import { useRouter } from "next/router";
import React, { FC } from "react";

const ProductPage = () => {
  const router = useRouter();
  const item = router.query.item;
  const itemId = parseInt(String(item), 10);
  const productById = useProductByIdQuery({
    variables: {
      itemId: itemId ?? -1,
    },
  });

  const checkIns = productById?.data?.checkIns;
  console.log("checkIns: ", checkIns);

  return (
    <SharedLayout
      title={`${item}`}
      titleHref={`/user/[item]`}
      titleHrefAs={`/user/${item}`}
      query={productById!}
    >
      {<ProductPageInner data={checkIns!} />}
    </SharedLayout>
  );
};

interface UserPageInnerProps {
  data: ProductByIdQuery["checkIns"];
}

const ProductPageInner: FC<UserPageInnerProps> = ({ data }) => {
  return (
    <div>
      <CardContainer>
        {data?.edges.map((checkIn) => (
          <Card key={checkIn.node.id}>
            <h3>{checkIn.node.item.flavor}</h3>
            {checkIn.node.item.checkIns.nodes.map((checkIn) => (
              <div key={checkIn.id}>
                {checkIn.author.name} {checkIn.rating / 2}
              </div>
            ))}
          </Card>
        ))}
      </CardContainer>
    </div>
  );
};

const CardContainer = styled("div", {
  display: "flex",
  flexDirection: "column",
  gap: "12px",
});

const Card = styled("div", {
  borderRadius: 6,
  padding: 24,
  width: "clamp(700px, 80vw)",
  backgroundColor: "white",
  boxShadow:
    "hsl(206 22% 7% / 35%) 0px 10px 38px -10px, hsl(206 22% 7% / 20%) 0px 10px 20px -15px",
  "@media (prefers-reduced-motion: no-preference)": {
    animationDuration: "400ms",
    animationTimingFunction: "cubic-bezier(0.16, 1, 0.3, 1)",
  },
});

export default ProductPage;
