import { parseSlug, paths, useFriendStatus } from "@pwa/common";
import {
  Card,
  FriendStatusIcon,
  Layout,
  SharedLayout,
  styled,
  SearchUsers,
} from "@pwa/components";
import { useSearchUsersLazyQuery, useSharedQuery } from "@pwa/graphql";
import { NextPage } from "next";
import Link from "next/link";
import { useRouter } from "next/router";
import React, { useEffect } from "react";

interface SearchFormInput {
  search: string;
}

const FriendsPage: NextPage = () => {
  const router = useRouter();
  const initialSearchValue = parseSlug(router.query.search);

  const shared = useSharedQuery();

  return (
    <SharedLayout
      title={`${shared.data?.currentUser?.username}`}
      query={shared}
    >
      <FriendsPageInner initialSearchValue={initialSearchValue} />
    </SharedLayout>
  );
};

const FriendsPageInner = ({
  initialSearchValue,
}: {
  initialSearchValue: string;
}) => {
  const [getUsers, { data, refetch }] = useSearchUsersLazyQuery();
  const { changeFriendStatus } = useFriendStatus({
    refetchQueries: ["SearchUsers"],
  });

  useEffect(() => {
    getUsers({ variables: { search: initialSearchValue } });
  }, [])

  const searchResults = data?.searchUsers;

  const onSubmit = async ({ search }: SearchFormInput) => {
    await getUsers({ variables: { search } });
  };

  return (
    <Layout.Root>
      <Layout.Header>
        <h1>Search Users</h1>
      </Layout.Header>
      <SearchUsers initialValue={initialSearchValue} onSubmit={onSubmit} />
      <Card.Container>
        {searchResults?.nodes.map((user) => (
          <Card.Wrapper key={user.id}>
            <Flex>
              <Link href={paths.user(user?.username ?? "")}>
                <h2>{user.username}</h2>
              </Link>
              <FriendStatusIcon
                friendStatus={user.friendStatus.nodes[0]}
                size="2x"
                onClick={() => {
                  changeFriendStatus(user.id, user.friendStatus.nodes[0]).then(
                    () => refetch && refetch()
                  );
                }}
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
