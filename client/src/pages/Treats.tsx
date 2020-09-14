import React, { useState } from "react";
import Header from "../components/Header";
import Card from "../components/Card";
import styled from "styled-components";
import { gql, useQuery } from "@apollo/client";
import { SearchTreats } from "../generated/SearchTreats";
import Input from "../components/Input";
import { ReactComponent as DropdownIcon } from "../assets/plus.svg";
import { Link } from "react-router-dom";

const Treats = () => {
  const [searchTerm, setSearchTerm] = useState("");

  const { data, loading } = useQuery<SearchTreats>(SEARCH_TREATS, {
    variables: { searchTerm },
  });

  return (
    <div>
      <Header>Treats</Header>
      <FlexWrapper>
        <Input
          value={searchTerm}
          onChange={({ target }) => setSearchTerm(target.value)}
          placeholder="Search for treats"
          width="740px"
        />
        <Button to="/treats/add">
          <DropdownIcon width="48px" fill="rgba(255, 255, 255, 0.247)" />
        </Button>
      </FlexWrapper>

      <CardContainer>
        {!loading && data
          ? data.searchTreats.map(({ name, id }) => (
              <Card key={`treat-${id}`}>{name}</Card>
            ))
          : null}
      </CardContainer>
    </div>
  );
};

const FlexWrapper = styled.div`
  display: flex;
`;

const Button = styled(Link)`
  background-color: inherit;
  outline: none;
  border: none;
`;

const SEARCH_TREATS = gql`
  query SearchTreats($searchTerm: String!) {
    searchTreats(searchTerm: $searchTerm) {
      id
      name
      company {
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
export default Treats;
