import { SharedLayout } from "@app/components";
import {
  BrandsByCompanyNameQuery,
  useBrandsByCompanyNameQuery,
} from "@app/graphql";
import { styled } from "@stitches/react";
import Link from "next/link";
import { useRouter } from "next/router";
import React, { FC } from "react";

const CompanyPage = ({ slug }: { slug: string }) => {
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
      titleHref={`/user/[slug]`}
      titleHrefAs={`/user/${slug}`}
      query={brands}
    >
      {data && <CompanyPageInner data={data} />}
    </SharedLayout>
  );
};

interface UserPageInnerProps {
  data: BrandsByCompanyNameQuery["companyByName"];
}

const CompanyPageInner: FC<UserPageInnerProps> = ({ data }) => {
  return (
    <div>
      <CardContainer>
        {data.brands.edges.map((brand) => (
          <Card key={brand.node.id}>
            <h3>{brand.node.name}</h3>
            {brand.node.items.edges.map((item) => (
              <div key={item.node.id}>
                <Link href={`/c/${data.name}/${item.node.id}`}>
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

export default CompanyPage;
