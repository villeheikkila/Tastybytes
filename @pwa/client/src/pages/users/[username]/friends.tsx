import { paths, useFriendStatus } from "@pwa/common";
import { Card, FriendStatusIcon, Layout, SharedLayout, styled } from "@pwa/components";
import {
  FriendsByUsernameQuery, useFriendsByUsernameQuery
} from "@pwa/graphql";
import { NextPage } from "next";
import Link from "next/link";
import { useRouter } from "next/router";
import React, { FC } from "react";
import { z } from "zod";

const parseSlug = z.string();

const FriendsPage: NextPage = () => {
  const router = useRouter();
  const username = parseSlug.parse(router.query.username);

  const query = useFriendsByUsernameQuery({variables: {username}});
  const data = query.data?.userByUsername;

  return (
    <SharedLayout
      title={`${query.data?.currentUser?.username ?? username}`}
      query={query}
    >
      {data && <FriendsPageInner data={data}  />}
    </SharedLayout>
  );
};

interface FriendsPageInnerProps {
  data: NonNullable<FriendsByUsernameQuery["userByUsername"]>;
}

const FriendsPageInner: FC<FriendsPageInnerProps> = ({ data }) => {
  const { changeFriendStatus } = useFriendStatus({
    refetchQueries: ["FriendsByUsername"],
  });

  return (
    <Layout.Root>
      <Layout.Header>
        <h1>Friends</h1>
      </Layout.Header>
      <Card.Container>
        {data.friends.nodes.map((friend) => (
          <Card.Wrapper key={friend.id}>
            <Flex>
              <Link href={paths.user(friend?.username ?? "")}>
                <h2>{friend.username}</h2>
              </Link>
              <FriendStatusIcon
                friendStatus={friend}
                size="2x"
                onClick={() =>
                  changeFriendStatus(friend.id, friend)
                }
              />
            </Flex>
          </Card.Wrapper>
        ))}

      </Card.Container>
    </Layout.Root>
  );
};

const Flex = styled("div", {
  display: "flex",
  justifyContent: "space-between",
  alignItems: "center",
});

export default FriendsPage;
