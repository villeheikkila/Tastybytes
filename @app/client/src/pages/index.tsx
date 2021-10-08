import { Card, Layout, SharedLayout, Stars } from "@app/components";
import {
  ActivityFeedQuery,
  useActivityFeedQuery,
  useSharedQuery,
} from "@app/graphql";
import { getDisplayName } from "@app/lib";
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
  data: ActivityFeedQuery["activityFeeds"];
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
              <Link href={`/u/${author.username}`}>
                {getDisplayName(author)}
              </Link>{" "}
              has tasted{" "}
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

export default Home;
