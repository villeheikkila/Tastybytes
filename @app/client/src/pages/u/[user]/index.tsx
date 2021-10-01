import { SharedLayout } from "@app/components";
import {
  ProductsByCompanyNameQuery,
  useProductsByCompanyNameQuery,
} from "@app/graphql";
import { styled } from "@stitches/react";
import Link from "next/link";
import { useRouter } from "next/router";
import React, { FC } from "react";

const ProfilePage = () => {
  const router = useRouter();
  const user = router.query.user;

  const checkIns = useProductsByCompanyNameQuery({
    variables: {
      companyName: String(user) ?? "",
    },
  });

  const data = checkIns.data?.companyByName;

  return (
    <SharedLayout
      title={`${data?.name ?? user}`}
      titleHref={`/user/[user]`}
      titleHrefAs={`/user/${user}`}
      query={checkIns!}
    >
      {<ProfilePageInner data={data!} />}
    </SharedLayout>
  );
};

interface UserPageInnerProps {
  data: ProductsByCompanyNameQuery["companyByName"];
}

const ProfilePageInner: FC<UserPageInnerProps> = ({ data }) => {
  return (
    <div>
      <CardContainer>
        {data?.brands.edges.map((brand) => (
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

export default ProfilePage;
