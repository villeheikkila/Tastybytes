import React from "react";
import styled from "styled-components";
import Text from "../../../components/Text";
import * as Types from "../../../types";

const ActivityCard = ({
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
      <Text>{treat.company.name}</Text> <Text>{treat.name}</Text>{" "}
      <Text>{treat.subcategory.name}</Text>
      <Text>{treat.category.name}</Text>
    </CardHeader>
    <CardScore>
      <Text>{score}</Text>
    </CardScore>
    <ReviewSection>
      <Text>{review}</Text>
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

export default ActivityCard;
