import { parseSlug, useFriendStatus } from "@pwa/common";
import {
  Card, Layout, SearchUsers, SharedLayout,
  styled
} from "@pwa/components";
import { useSearchItemsLazyQuery, useSharedQuery } from "@pwa/graphql";
import { NextPage } from "next";
import Link from "next/link";
import { useRouter } from "next/router";
import React, { useEffect } from "react";

interface SearchFormInput {
  search: string;
}

const SearchPage: NextPage = () => {
  const router = useRouter();
  const initialSearchValue = parseSlug(router.query.query);

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
  const [getUsers, { data, refetch }] = useSearchItemsLazyQuery();
  const { changeFriendStatus } = useFriendStatus({
    refetchQueries: ["SearchUsers"],
  });

  useEffect(() => {
    getUsers({ variables: { search: initialSearchValue } });
  }, [])

  const searchResults = data?.searchItems;

  const onSubmit = async ({ search }: SearchFormInput) => {
    await getUsers({ variables: { search } });
  };

  return (
    <Layout.Root>
      <Layout.Header>
        <h1>Search Items</h1>
      </Layout.Header>
      <SearchUsers initialValue={initialSearchValue} onSubmit={onSubmit} />
      <Card.Container>
        {searchResults?.nodes.map((item) => (
          <Card.Wrapper key={item.id}>
            <Flex>
              <Link href={`/company/${item?.brand?.company?.name ?? ""}`}>
                <h2>{item?.brand?.company?.name ?? ""}</h2>
              </Link>
              <Link href={`/company/${item?.brand?.company?.name ?? ""}`}>
                <p>{item.brand?.name}</p>
              </Link>
              <Link href={`/company/${item?.brand?.company?.name ?? ""}/${item.id}`}>
                <p>{item.flavor}</p>
              </Link>
            </Flex>
          </Card.Wrapper>
        ))}
      </Card.Container>
    </Layout.Root>
  );
};

const Flex = styled("div", {
  display: "flex",
  flexDirection: "column"
});

export default SearchPage;
