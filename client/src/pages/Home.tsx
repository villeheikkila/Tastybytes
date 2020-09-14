import React from "react";
import Header from "../components/Header";
import { gql, useQuery } from "@apollo/client";
import Card from "../components/Card";
import styled from "styled-components";
import { Reviews } from "../generated/Reviews";
import Spinner from "../components/Spinner";

const Home = () => {
  const { data, loading } = useQuery<Reviews>(GET_REVIEWS);

  if (loading || !data) return <Spinner />;

  return (
    <div>
      <Header>Home</Header>
      <CardContainer>
        {data.reviews.map(({ id, score, review, treat }: any) => (
          <Card key={`review-card-${id}`}>
            {review} {score} {treat.producedBy.name} {treat.name}
          </Card>
        ))}
      </CardContainer>
    </div>
  );
};

const CardContainer = styled.div`
  display: grid;
  grid-gap: 10px;
`;

const GET_REVIEWS = gql`
  query Reviews {
    reviews {
      id
      review
      score
      treat {
        name
        company {
          name
        }
      }
    }
  }
`;

export default Home;
