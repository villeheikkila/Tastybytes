import { SharedLayout } from "@app/components";
import {
  CheckInsByUsernameQuery,
  useCheckInsByUsernameQuery,
  User,
} from "@app/graphql";
import { faStar, faStarHalfAlt } from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { styled } from "@stitches/react";
import { NextPage } from "next";
import { useRouter } from "next/router";
import React, { FC } from "react";
import { z } from "zod";

const parseSlug = z.string();

const Stars = ({ rating }: { rating: number }) => {
  return (
    <div>
      {Array.from({ length: Math.floor(rating / 2) }, (_, i) => (
        <FontAwesomeIcon
          icon={faStar}
          key={i}
          color="rgba(242, 204, 0, 1.00)"
        />
      ))}
      {rating % 2 !== 0 && (
        <FontAwesomeIcon icon={faStarHalfAlt} color="rgba(242, 204, 0, 1.00)" />
      )}
    </div>
  );
};

const getDisplayName = ({
  firstName,
  lastName,
  username,
}: Pick<User, "firstName" | "lastName" | "username">) =>
  firstName && lastName ? `${firstName} ${lastName}` : username;

const UserPage: NextPage = () => {
  const router = useRouter();
  const username = parseSlug.parse(router.query.username);

  const user = useCheckInsByUsernameQuery({
    variables: {
      username: username,
    },
  });

  const data = user.data?.userByUsername;

  return (
    <SharedLayout
      title={`${data?.username ?? username}`}
      titleHref={`/user/[username]`}
      titleHrefAs={`/user/${username}`}
      query={user}
    >
      {data && <UserPageInner user={data} />}
    </SharedLayout>
  );
};

interface UserPageInnerProps {
  user: CheckInsByUsernameQuery["userByUsername"];
}

const UserPageInner: FC<UserPageInnerProps> = ({ user }) => {
  return (
    <Wrapper>
      <Header>
        <h1>Ville Heikkilä</h1>
        <p>Total check-ins: {user?.authoredCheckIns.totalCount}</p>
      </Header>
      <CardContainer>
        {user?.authoredCheckIns.nodes.map((checkIn) => (
          <Card key={checkIn.id}>
            <p>
              <b>{getDisplayName(user)}</b> is tasting a
              {` ${checkIn.item.brand.name} - ${checkIn.item.flavor}`} by{" "}
              {checkIn.item.brand.company.name}
            </p>
            <Stars rating={checkIn.rating} />
          </Card>
        ))}
      </CardContainer>
    </Wrapper>
  );
};

const Wrapper = styled("div", {
  display: "flex",
  flexDirection: "column",
  gap: "12px",
  justify: "center",
  alignItems: "center",
});
const Header = styled("div", { display: "flex", flexDirection: "column" });

const CardContainer = styled("div", {
  display: "flex",
  flexDirection: "column",
  gap: "12px",
});

const Card = styled("div", {
  display: "flex",
  flexDirection: "column",
  gap: "4px",
  borderRadius: 6,
  padding: 24,
  width: "clamp(700px, 80vw)",
  backgroundColor: "rgba(45, 46, 48, 1.00)",
  boxShadow:
    "hsl(206 22% 7% / 35%) 0px 10px 38px -10px, hsl(206 22% 7% / 20%) 0px 10px 20px -15px",
  "@media (prefers-reduced-motion: no-preference)": {
    animationDuration: "400ms",
    animationTimingFunction: "cubic-bezier(0.16, 1, 0.3, 1)",
  },
});

export default UserPage;
