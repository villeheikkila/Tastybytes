import { paths, useFriendStatus } from "@pwa/common";
import {
  Button,
  Card,
  FriendStatusIcon,
  Input,
  Layout,
  SharedLayout,
  styled
} from "@pwa/components";
import {
  useSearchUsersLazyQuery,
  useSharedQuery
} from "@pwa/graphql";
import { NextPage } from "next";
import Link from "next/link";
import React from "react";
import { useForm } from "react-hook-form";

interface SearchFormInput {
  search: string;
}

const FriendsPage: NextPage = () => {
  const shared = useSharedQuery();

  return (
    <SharedLayout
      title={`${shared.data?.currentUser?.username}`}
      query={shared}
    >
      <FriendsPageInner />
    </SharedLayout>
  );
};

const FriendsPageInner = () => {
  const [getUsers, { data, refetch }] = useSearchUsersLazyQuery();
  const { changeFriendStatus } = useFriendStatus({
    refetchQueries: ["SearchUsers"],
  });

  const searchResults = data?.searchUsers;

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<SearchFormInput>();

  const onSubmit = async ({ search }: SearchFormInput) => {
    await getUsers({ variables: { search } });
  };

  return (
    <Layout.Root>
      <Layout.Header>
        <h1>Search Users</h1>
      </Layout.Header>
      <Form onSubmit={handleSubmit(onSubmit)}>
        <Input
          id="search"
          autoComplete="search"
          placeholder="search"
          aria-invalid={errors.search ? "true" : "false"}
          {...register("search", {
            required: true,
            min: 2,
          })}
        />
        <Button type="submit">Search</Button>
      </Form>
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
                  changeFriendStatus(
                    user.id,
                    user.friendStatus.nodes[0]
                  ).then(() => refetch && refetch());
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

const Form = styled("form", {
  display: "flex",
  alignItems: "center",
  gap: "12px",
});

export default FriendsPage;
