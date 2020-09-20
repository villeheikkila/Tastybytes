import React from "react";
import { Link } from "react-router-dom";
import styled from "styled-components";
import { SearchTreats_searchTreats } from "../../../generated/SearchTreats";
import Text from "../../../components/Text";

const TreatCard = (props: SearchTreats_searchTreats) => (
  <>
    <CardContent>
      <Link to={`/treats/add-review/${props.id}`}>
        <Text>Treat: {props.name}</Text>{" "}
      </Link>

      <Text>Company: {props.company.name}</Text>
      <Text>Category: {props.category.name}</Text>
      <Text>Subcategory: {props.subcategory.name}</Text>
    </CardContent>
  </>
);

const CardContent = styled.div`
  display: grid;
  grid-gap: 5px;
  width: 100%;
  height: 100%;
`;

export default TreatCard;
