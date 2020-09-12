import React from "react";
import Header from "../components/Header";
import Card from "../components/Card";
import styled from "styled-components";
import { gql, useQuery } from "@apollo/client";
import { SearchTreats } from "../generated/SearchTreats";

const Home = () => {
  const { data, loading } = useQuery<SearchTreats>(SEARCH_TREATS);

  return (
    <div>
      <Header>Home</Header>
      {!loading && data ? (
        <CardContainer>
          {data.treats.map(({ name, id }) => (
            <Card key={`treat-${id}`}>{name}</Card>
          ))}
        </CardContainer>
      ) : null}
    </div>
  );
};

const SEARCH_TREATS = gql`
  query SearchTreats {
    treats {
      id
      name
      producedBy {
        name
        id
      }
      reviews {
        score
        review
        author {
          firstName
          lastName
        }
      }
    }
  }
`;

const CardContainer = styled.div`
  display: grid;
  grid-gap: 15px;
`;
export default Home;
