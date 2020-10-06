import React from "react";
import Cards from "../../components/Cards";
import Header from "../../components/Header";
import Spinner from "../../components/Spinner";
import ActivityCard from "./components/ActivityCard";
import { useReviewsQuery } from "./queries.hooks";

export const Activity = () => {
  const { data, loading, fetchMore } = useReviewsQuery();
  if (loading || !data) return <Spinner />;

  const onLoadMore = () =>
    fetchMore({
      variables: {
        offset: data.reviews.length,
      },

      // TODO: Fix the typing mess
      updateQuery: (prev: any, { fetchMoreResult }: any) => {
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
