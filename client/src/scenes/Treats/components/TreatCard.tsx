import React from "react";
import { Link } from "react-router-dom";
import styled from "styled-components";
import { Typography } from "../../../components";
import * as Types from "../../../types";

export const TreatCard = (
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
        <Typography>Treat: {props.name}</Typography>{" "}
      </Link>

      <Typography>Company: {props.company.name}</Typography>
      <Typography>Category: {props.category.name}</Typography>
      <Typography>Subcategory: {props.subcategory.name}</Typography>
    </CardContent>
  </>
);

const CardContent = styled.div`
  display: grid;
  grid-gap: 5px;
  width: 100%;
  height: 100%;
`;
