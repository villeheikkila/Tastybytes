import React from "react";
import Header from "../../components/Header";
import { useQuery } from "@apollo/client";
import { Reviews } from "../../generated/Reviews";
import Spinner from "../../components/Spinner";
import Cards from "../../components/Cards";
import { GET_REVIEWS } from "./graphql";
import ActivityCard from "./components/ActivityCard";

export const Activity = () => {
  const { data, loading } = useQuery<Reviews>(GET_REVIEWS);
  if (loading || !data) return <Spinner />;

  return (
    <div>
      <Header>Activity</Header>
      {!loading && data && (
        <Cards
          reduceHeight={150}
          data={data.reviews}
          component={ActivityCard}
        ></Cards>
      )}
    </div>
  );
};
