import React, { useState } from "react";
import { useQuery } from "@apollo/client";
import { SearchTreats } from "../../generated/SearchTreats";
import Input from "../../components/HeaderInput";
import Cards from "../../components/Cards";
import { SEARCH_TREATS } from "./graphql";
import Container from "../../components/Container";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faPlusCircle } from "@fortawesome/free-solid-svg-icons";
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
      <Container>
        <Input
          value={searchTerm}
          onChange={({ target }) => setSearchTerm(target.value)}
          placeholder="Search for treats"
        />
        <IconButton to="/treats/add">
          <FontAwesomeIcon
            icon={faPlusCircle}
            size="lg"
            color={theme.colors.darkGray}
          />
        </IconButton>
      </Container>

      {!loading && data && (
        <Cards
          reduceHeight={150}
          data={data.searchTreats}
          component={TreatCard}
        />
      )}
    </div>
  );
};

export default Treats;
