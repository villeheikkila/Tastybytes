import { SharedLayout, useOrganizationSlug } from "@app/components";
import {
  CheckInsByUsernameQuery,
  ProductsByCompanyNameQuery,
  ProductsByCompanyNameQueryResult,
  useProductsByCompanyNameQuery,
} from "@app/graphql";
import { styled } from "@stitches/react";
import { NextPage } from "next";
import Link from "next/link";
import { useRouter } from "next/router";
import React, { FC } from "react";

export function useCatchAllSlug() {
  const router = useRouter();
  const { slug } = router.query;
  return slug;
}

const CompanyPageRouter: NextPage = () => {
  const slug = useCatchAllSlug();

  if (slug?.length === 1) {
    return <CompanyPage slug={slug[0]} />;
  } else {
    return <ProductPage slug={slug} />;
  }
};

const CompanyPage = ({ slug }: { slug: string }) => {
  const checkIns = useProductsByCompanyNameQuery({
    variables: {
      companyName: slug![0] ?? "",
    },
  });

  const data = checkIns.data?.companyByName;
  console.log("checkIns: ", checkIns);

  return (
    <SharedLayout
      title={`${data?.name ?? slug}`}
      titleHref={`/user/[slug]`}
      titleHrefAs={`/user/${slug}`}
      query={checkIns!}
    >
      {<CompanyPageInner data={data!} />}
    </SharedLayout>
  );
};

const ProductPage = ({ slug }: { slug: string }) => {
  const checkIns = useProductsByCompanyNameQuery({
    variables: {
      companyName: slug![0] ?? "",
    },
  });

  const data = checkIns.data?.companyByName;
  console.log("checkIns: ", checkIns);

  return (
    <SharedLayout
      title={`${data?.name ?? slug}`}
      titleHref={`/user/[slug]`}
      titleHrefAs={`/user/${slug}`}
      query={checkIns!}
    >
      {<CompanyPageInner data={data!} />}
    </SharedLayout>
  );
};

interface UserPageInnerProps {
  data: ProductsByCompanyNameQuery["companyByName"];
}

const CompanyPageInner: FC<UserPageInnerProps> = ({ data }) => {
  return (
    <div>
      <CardContainer>
        {data?.brands.edges.map((brand) => (
          <Card key={brand.node.id}>
            <h3>{brand.node.name}</h3>
            {brand.node.items.edges.map((item) => (
              <div key={item.node.id}>
                <Link href={`/c/${data.name}/${item.node.flavor}`}>
                  {item.node.flavor}
                </Link>
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

export default CompanyPageRouter;
