import React from "react";
import styled from "styled-components";
import { Typography } from "../../../components";
import * as Types from "../../../types";

export const ActivityCard = ({
  score,
  review,
  treat,
}: Pick<Types.Review, "id" | "review" | "score"> & {
  treat: Pick<Types.Treat, "name"> & {
    category: Pick<Types.Category, "name">;
    subcategory: Pick<Types.Subcategory, "name">;
    company: Pick<Types.Company, "name">;
  };
}) => (
  <CardContainer>
    <CardHeader>
      <Typography>{treat.company.name}</Typography> 
      <Typography>{treat.name}</Typography>{" "}
      <Typography>{treat.subcategory.name}</Typography>
      <Typography>{treat.category.name}</Typography>
    </CardHeader>
    <CardScore>
      <Typography>{score}</Typography>
    </CardScore>
    <ReviewSection>
      <Typography>{review}</Typography>
    </ReviewSection>
  </CardContainer>
);

const CardContainer = styled.div`
  border-radius: 8px;
  padding: 8px;
  display: grid;
  grid-template-areas: "header" "." "score" "." "content";
  grid-template-rows: 1fr 50px 1fr 50px 3fr;
`;

const CardHeader = styled.div`
  grid-area: header;
  font-size: 24px;
  font-weight: 600;
  display: grid;
  grid-auto-flow: column;
  height: 20px;
  grid-template-columns: 0.5fr 0.5fr 3fr 0.5fr 0.5fr;
`;

const CardScore = styled.div`
  grid-area: score;
`;

const ReviewSection = styled.div`
  grid-area: content;
`;
