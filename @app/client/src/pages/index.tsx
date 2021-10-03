import { SharedLayout } from "@app/components";
import { useSharedQuery } from "@app/graphql";
import { NextPage } from "next";
import * as React from "react";

const Home: NextPage = () => {
  const query = useSharedQuery();

  return (
    <SharedLayout title="Activity" query={query}>
      <div />
    </SharedLayout>
  );
};

export default Home;
