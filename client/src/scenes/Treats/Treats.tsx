import React, { useState, useEffect } from "react";
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
import Button from "../../components/Button";
import { useIntersectionObserver } from "react-intersection-observer-hook";

const Treats = () => {
  const [searchTerm, setSearchTerm] = useState("");
  const [ref, { entry }] = useIntersectionObserver();

  const isVisible = entry && entry.isIntersecting;

  useEffect(() => {
    console.log(`The component is ${isVisible ? "visible" : "not visible"}.`);
  }, [isVisible]);

  const { data, loading, error, fetchMore } = useQuery<SearchTreats>(
    SEARCH_TREATS,
    {
      variables: { searchTerm, offset: 0 },
    }
  );
  console.log("error: ", error);

  if (!data) return null;

  const onLoadMore = () =>
    fetchMore({
      variables: {
        offset: data.searchTreats.length,
      },
      updateQuery: (prev, { fetchMoreResult }) => {
        if (!fetchMoreResult) return prev;
        return Object.assign({}, prev, {
          searchTreats: [...prev.searchTreats, ...fetchMoreResult.searchTreats],
        });
      },
    });

  const onDragEnd = (event: any, info: any) => {
    if (info.point.y > 400) {
      onLoadMore();
    }
  };

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

      <Button onClick={() => onLoadMore()}>Load More</Button>
      {!loading && data && (
        <Cards
          reduceHeight={300}
          onDragEnd={onDragEnd}
          data={data.searchTreats}
          component={TreatCard}
        />
      )}
    </div>
  );
};

export default Treats;
