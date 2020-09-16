import React, { useState } from "react";
import Header from "../../components/Header";
import styled from "styled-components";
import { useQuery } from "@apollo/client";
import {
  SearchTreats,
  SearchTreats_searchTreats,
} from "../../generated/SearchTreats";
import Input from "../../components/LargeInput";
import { ReactComponent as DropdownIcon } from "../../assets/plus.svg";
import { Link } from "react-router-dom";
import Cards from "../../components/Cards";
import { SEARCH_TREATS } from "./graphql";

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

      {!loading && data && (
        <Cards reduceHeight={350} data={data.searchTreats} component={Card1} />
      )}
    </div>
  );
};

const Card1 = (props: SearchTreats_searchTreats) => <>{props.company.name}</>;

const FlexWrapper = styled.div`
  display: flex;
`;

const Button = styled(Link)`
  background-color: inherit;
  outline: none;
  border: none;
`;

export default Treats;
