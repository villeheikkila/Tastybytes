import React, { useState } from "react";
import { useForm } from "react-hook-form";
import { useParams } from "react-router-dom";
import styled from "styled-components";
import { theme } from "../../common";
import {
  Button,
  Cards,
  Container,
  Heading,
  Spacer,
  StarPicker,
  Typography,
} from "../../components";
import { Review } from "../../types";
import { useCreateReviewMutation, useGetTreatQuery } from "./queries.hooks";

const AddReview: React.FC = () => {
  const [score, setScore] = useState(0);

  const { id } = useParams<{ id: string }>();
  const { data, loading } = useGetTreatQuery({
    variables: { id },
  });

  const [createReview] = useCreateReviewMutation({
    refetchQueries: ["GetTreat"],
  });

  const { register, handleSubmit } = useForm<{
    score: string;
    review: string;
  }>();

  const onSubmit = handleSubmit(async ({ review }) => {
    // TODO: Handle errors
    if (!score) return;

    try {
      await createReview({
        variables: {
          review: { treatId: id, score, review },
        },
      });
    } catch (error) {
      console.error(error);
    }
  });

  if (loading || !data) return null;

  const reviews = data.treat.reviews;

  return (
    <Page>
      <Card>
        <Heading>{data.treat.name}</Heading>
        <Spacer y amount={12} />
        <Typography>{data.treat.company.name}</Typography>
        <Spacer y amount={12} />
        <Container>
          <Chip>
            <Typography>{data.treat.category.name} </Typography>
          </Chip>
          <Spacer x amount={8} />
          <Chip>
            <Typography>{data.treat.subcategory.name}</Typography>
          </Chip>
        </Container>
      </Card>

      <Spacer y amount={20} />

      <Card>
        <Form onSubmit={onSubmit}>
          <TextArea
            placeholder="Add review"
            name="review"
            rows={5}
            ref={register({ required: false })}
          />
          <StarPicker score={score} setScore={setScore} />

          <Button type="submit">Check-in!</Button>
        </Form>
      </Card>

      <Spacer y amount={20} />

      <Cards reduceHeight={550} data={reviews} component={ReviewCard} />
    </Page>
  );
};

const ReviewCard = ({
  review,
  score,
}: Pick<Review, "id" | "review" | "score">) => (
  <>
    {review} {score}
  </>
);

const TextArea = styled.textarea`
  border-radius: 8px;
  display: block;
  border: 1px solid ${(props) => props.theme.colors.black};
  background-color: ${(props) => props.theme.colors.primary};
  border: none;
  ${theme.typography.body};
  resize: none;
  width: 100%;
`;

const Chip = styled.div`
  border-radius: 8px;
  padding: 4px;
  background-color: ${(props) => props.theme.colors.blue};
`;

const Card = styled.div`
  border-radius: 8px;
  background-color: ${(props) => props.theme.colors.primary};
  padding: 20px;
  max-width: 800px;
`;

const Form = styled.form`
  display: grid;
  width: 100%;
  grid-gap: 20px;
`;

const Page = styled.div`
  display: flex;
  flex-direction: column;
  padding: 10px;
  max-width: 800px;
  font-size: 28px;
  border-radius: 8px;

  @media (max-width: 800px) {
    width: calc(100vw);
  }
`;

export default AddReview;
