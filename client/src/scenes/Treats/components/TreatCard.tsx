import React from "react";
import { Link } from "react-router-dom";
import styled from "styled-components";
import Text from "../../../components/Text";
import * as Types from "../../../types";

const TreatCard = (
  props: Pick<Types.Treat, "id" | "name"> & {
    company: Pick<Types.Company, "name" | "id">;
    category: Pick<Types.Category, "id" | "name">;
    subcategory: Pick<Types.Subcategory, "id" | "name">;
    reviews: Array<
      Pick<Types.Review, "id" | "score" | "review"> & {
        author: Pick<Types.Account, "username">;
      }
    >;
  }
) => (
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
