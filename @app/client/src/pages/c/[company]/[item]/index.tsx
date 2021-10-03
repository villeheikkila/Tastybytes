import { Card, Layout, SharedLayout, Stars } from "@app/components";
import { ProductByIdQuery, useProductByIdQuery } from "@app/graphql";
import { getDisplayName } from "@app/lib";
import Link from "next/link";
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

  const data = productById?.data?.item;

  return (
    <SharedLayout
      title={`${item}`}
      titleHref={`/c/[company]/[item]`}
      titleHrefAs={`/c/[company]/${item}`}
      query={productById}
    >
      {data && <ProductPageInner data={data} />}
    </SharedLayout>
  );
};

interface UserPageInnerProps {
  data: ProductByIdQuery["item"];
}

const ProductPageInner: FC<UserPageInnerProps> = ({ data }) => {
  return (
    <Layout.Root>
      <Layout.Header>
        <h1>
          {data.brand.company.name} {data.brand.name} {data.flavor}
        </h1>
      </Layout.Header>

      <Card.Container>
        {data.checkIns.nodes.map(({ id, author, rating }) => (
          <Card.Wrapper key={id}>
            <p>
              <b>{getDisplayName(author)}</b> has tasted{" "}
              <Link
                href={`/c/${data.brand.company.name}/${data.id}`}
              >{`${data.brand.name} - ${data.flavor}`}</Link>{" "}
              by{" "}
              <Link href={`/c/${data.brand.company.name}`}>
                {data.brand.company.name}
              </Link>
            </p>
            <Stars rating={rating} />
          </Card.Wrapper>
        ))}
      </Card.Container>
    </Layout.Root>
  );
};

export default ProductPage;
