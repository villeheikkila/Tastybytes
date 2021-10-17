import { Card, Layout, SharedLayout, Stars } from "@pwa/components";
import {
  ActivityFeedQuery,
  useActivityFeedQuery,
  useSharedQuery,
} from "@pwa/graphql";
import { getDisplayName, paths } from "@pwa/common";
import { NextPage } from "next";
import Link from "next/link";
import * as React from "react";

const Home: NextPage = () => {
  const query = useSharedQuery();
  const activityFeed = useActivityFeedQuery();
  const data = activityFeed.data?.activityFeeds;
  console.log("data: ", data);

  return (
    <SharedLayout title="Activity" query={query}>
      {data && <ActivityFeed data={data} />}
    </SharedLayout>
  );
};

interface ActivityFeedProps {
  data: NonNullable<ActivityFeedQuery["activityFeeds"]>;
}

const ActivityFeed: React.FC<ActivityFeedProps> = ({ data }) => {
  return (
    <Layout.Root>
      <Layout.Header>
        <h1>Activity Feed</h1>
      </Layout.Header>
      <Card.Container>
        {data.nodes.map(({ id, item, rating, author }) => (
          <Card.Wrapper key={id}>
            <p>
              <Link href={paths.user(author?.username ?? "")}>
                {author && getDisplayName(author)}
              </Link>{" "}
              has tasted{" "}
              <Link
                href={`/c/${item?.brand?.company?.name}/${item?.id}`}
              >{`${item?.brand?.name} - ${item?.flavor}`}</Link>{" "}
              by{" "}
              <Link href={`/c/${item?.brand?.company?.name}`}>
                {item?.brand?.company?.name}
              </Link>
            </p>
            {rating && <Stars rating={rating} />}
          </Card.Wrapper>
        ))}
      </Card.Container>
    </Layout.Root>
  );
};

export default Home;
