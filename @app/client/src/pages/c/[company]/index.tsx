import { Card, Layout, SharedLayout } from "@app/components";
import {
  BrandsByCompanyNameQuery,
  useBrandsByCompanyNameQuery,
} from "@app/graphql";
import Link from "next/link";
import { useRouter } from "next/router";
import React, { FC } from "react";

const CompanyPage = () => {
  const router = useRouter();
  const companyName = router.query.company;

  const brands = useBrandsByCompanyNameQuery({
    variables: {
      companyName: String(companyName) ?? "",
    },
  });

  const data = brands.data?.companyByName;

  return (
    <SharedLayout
      title={`${data?.name ?? companyName}`}
      titleHref={`/c/[company]`}
      titleHrefAs={`/c/${companyName}`}
      query={brands}
    >
      {data && <CompanyPageInner data={data} />}
    </SharedLayout>
  );
};

interface UserPageInnerProps {
  data: NonNullable<BrandsByCompanyNameQuery["companyByName"]>;
}

const CompanyPageInner: FC<UserPageInnerProps> = ({ data }) => {
  return (
    <Layout.Root>
      <Layout.Header>
        <h1>{data.name}</h1>
      </Layout.Header>
      <Card.Container>
        {data.brands.edges.map((brand) => (
          <Card.Wrapper key={brand.node.id}>
            <h3>{brand.node.name}</h3>
            {brand.node.items.edges.map((item) => (
              <div key={item.node.id}>
                <Link href={`/c/${data.name}/${item.node.id}`}>
                  {item.node.flavor}
                </Link>
              </div>
            ))}
          </Card.Wrapper>
        ))}
      </Card.Container>
    </Layout.Root>
  );
};

export default CompanyPage;
