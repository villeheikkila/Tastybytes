import { Card, Layout, SharedLayout, Stars } from "@app/components";
import {
  CheckInsByUsernameQuery,
  useCheckInsByUsernameQuery,
} from "@app/graphql";
import { getDisplayName } from "@app/lib";
import { NextPage } from "next";
import Link from "next/link";
import { useRouter } from "next/router";
import React, { FC } from "react";
import { z } from "zod";

const parseSlug = z.string();

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
    <Layout.Root>
      <Layout.Header>
        <h1>Ville Heikkilä</h1>
        <p>Total check-ins: {user?.authoredCheckIns.totalCount}</p>
      </Layout.Header>
      <Card.Container>
        {user?.authoredCheckIns.nodes.map(({ id, item, rating }) => (
          <Card.Wrapper key={id}>
            <p>
              <b>{getDisplayName(user)}</b> has tasted{" "}
              <Link
                href={`/c/${item.brand.company.name}/${item.id}`}
              >{`${item.brand.name} - ${item.flavor}`}</Link>{" "}
              by{" "}
              <Link href={`/c/${item.brand.company.name}`}>
                {item.brand.company.name}
              </Link>
            </p>
            <Stars rating={rating} />
          </Card.Wrapper>
        ))}
      </Card.Container>
    </Layout.Root>
  );
};

export default UserPage;
