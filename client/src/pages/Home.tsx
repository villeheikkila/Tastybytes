import React from "react";
import Header from "../components/Header";
import { gql, useQuery } from "@apollo/client";
import styled from "styled-components";
import { Reviews, Reviews_reviews } from "../generated/Reviews";
import Spinner from "../components/Spinner";
import Cards from "../components/Cards";

const Home = () => {
  const { data, loading } = useQuery<Reviews>(GET_REVIEWS);
  if (loading || !data) return <Spinner />;

  return (
    <div>
      <Header>Home</Header>
      {!loading && data && (
        <Cards reduceHeight={150} data={data.reviews} component={Card1}></Cards>
      )}
    </div>
  );
};

const Card = styled.div`
  border-radius: 8px;
  display: grid;
  grid-template-areas: "header" "score" "content";
  grid-template-rows: 1fr 1fr 5fr;
`;

const Card1 = (props: Reviews_reviews) => <Card>{props.score}</Card>;

const CardHeader = styled.div`
  grid-area: "header";
  font-size: 24px;
  font-weight: 600;
  display: grid;
  grid-auto-flow: column;
  height: 20px;
  grid-template-columns: 1fr 1fr 0.5fr 0.5fr;
`;

const CardScore = styled.div`
  grid-area: "score";
`;

const CardContent = styled.div`
  grid-area: "content";
`;

const GET_REVIEWS = gql`
  query Reviews {
    reviews {
      id
      review
      score
      treat {
        name
        category {
          name
        }
        subcategory {
          name
        }
        company {
          name
        }
      }
    }
  }
`;

export default Home;
