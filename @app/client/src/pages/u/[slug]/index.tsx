import { SharedLayout, useOrganizationSlug } from "@app/components";
import {
  CheckInsByUsernameQuery,
  useCheckInsByUsernameQuery,
} from "@app/graphql";
import { styled } from "@stitches/react";
import { NextPage } from "next";
import React, { FC } from "react";

const UserPage: NextPage = () => {
  const slug = useOrganizationSlug();
  const checkIns = useCheckInsByUsernameQuery({
    variables: {
      username: slug,
    },
  });

  const data = checkIns.data?.userByUsername;

  return (
    <SharedLayout
      title={`${data?.name ?? slug}`}
      titleHref={`/user/[slug]`}
      titleHrefAs={`/user/${slug}`}
      query={checkIns!}
    >
      {<UserPageInner user={data!} />}
    </SharedLayout>
  );
};

interface UserPageInnerProps {
  user: CheckInsByUsernameQuery["userByUsername"];
}

const UserPageInner: FC<UserPageInnerProps> = ({ user }) => {
  return (
    <div>
      <span>Total check-ins: {user?.authoredCheckIns.totalCount}</span>
      <CardContainer>
        {user?.authoredCheckIns.nodes.map((checkIn) => (
          <Card key={checkIn.id}>
            {user.name} is tasting a{" "}
            {`${checkIn.item.brand.name} - ${checkIn.item.flavor}`} by{" "}
            {checkIn.item.brand.company.name} and gave it a rating of{" "}
            {checkIn.rating / 2}
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

export default UserPage;
