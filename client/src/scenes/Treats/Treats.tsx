import React, { useState } from "react";
import Header from "../../components/Header";
import { useQuery } from "@apollo/client";
import { SearchTreats } from "../../generated/SearchTreats";
import Input from "../../components/HeaderInput";
import { ReactComponent as DropdownIcon } from "../../assets/plus.svg";
import Cards from "../../components/Cards";
import { SEARCH_TREATS } from "./graphql";
import Container from "../../components/Container";
import theme from "../../theme";
import IconButton from "../../components/IconButton";
import TreatCard from "./components/TreatCard";

const Treats = () => {
  const [searchTerm, setSearchTerm] = useState("");

  const { data, loading } = useQuery<SearchTreats>(SEARCH_TREATS, {
    variables: { searchTerm },
  });

  return (
    <div>
      <Header>Treats</Header>
      <Container>
        <Input
          value={searchTerm}
          onChange={({ target }) => setSearchTerm(target.value)}
          placeholder="Search for treats"
        />
        <IconButton to="/treats/add">
          <DropdownIcon width="48px" fill={theme.colors.darkGray} />
        </IconButton>
      </Container>

      {!loading && data && (
        <Cards
          reduceHeight={350}
          data={data.searchTreats}
          component={TreatCard}
        />
      )}
    </div>
  );
};

export default Treats;
