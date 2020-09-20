import React from "react";
import Header from "../../components/Header";
import { useQuery } from "@apollo/client";
import { Reviews } from "../../generated/Reviews";
import Spinner from "../../components/Spinner";
import Cards from "../../components/Cards";
import { GET_REVIEWS } from "./graphql";
import ActivityCard from "./components/ActivityCard";

export const Activity = () => {
  const { data, loading, fetchMore } = useQuery<Reviews>(GET_REVIEWS);
  if (loading || !data) return <Spinner />;

  const onLoadMore = () =>
    fetchMore({
      variables: {
        offset: data.reviews.length,
      },
      updateQuery: (prev, { fetchMoreResult }) => {
        if (!fetchMoreResult) return prev;
        return Object.assign({}, prev, {
          reviews: [...prev.reviews, ...fetchMoreResult.reviews],
        });
      },
    });

  // TODO: Find saner way to fetch more
  const onDragEnd = (event: any, info: any) => {
    if (info.offset.y < 0) {
      console.log("info: ", info);
      console.log("fetch more!");
      onLoadMore();
    }
  };

  return (
    <div>
      <Header>Activity</Header>
      {!loading && data && (
        <Cards
          reduceHeight={150}
          data={data.reviews}
          component={ActivityCard}
          onDragEnd={onDragEnd}
        />
      )}
    </div>
  );
};
