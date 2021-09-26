import { SharedLayout } from "@app/components";
import { styled } from "@app/components/stitches.config";
import { useCheckInsByUserQuery, useSharedQuery } from "@app/graphql";
import { NextPage } from "next";
import { check } from "prettier";
import * as React from "react";

const Text = styled("p", {
  fontFamily: "$system",
  color: "$hiContrast",

  variants: {
    size: {
      1: {
        fontSize: "$1",
      },
      2: {
        fontSize: "$2",
      },
      3: {
        fontSize: "$3",
      },
    },
  },
});

const Home: NextPage = () => {
  const query = useSharedQuery();

  return (
    <SharedLayout title="" query={query}>
      <Text as="h1" size="3">
        Check-ins
      </Text>
    </SharedLayout>
  );
};

export default Home;
