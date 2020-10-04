import React, { useState } from "react";
import styled from "styled-components";
import { useForm } from "react-hook-form";
import { useMutation, useQuery } from "@apollo/client";
import { useParams } from "react-router-dom";
import { GetTreat, GetTreat_treat_reviews } from "../../generated/GetTreat";
import { CreateReview } from "../../generated/CreateReview";
import { GET_TREAT, CREATE_REVIEW } from "./grapqhl";
import Heading from "../../components/Heading";
import Text from "../../components/Text";
import Spacer from "../../components/Spacer";
import Container from "../../components/Container";
import Cards from "../../components/Cards";
import Button from "../../components/Button";
import StarPicker from "../../components/StarPicker";

export const AddReview: React.FC = () => {
  const [score, setScore] = useState(0);

  const { id } = useParams<{ id: string }>();
  const { data, loading } = useQuery<GetTreat>(GET_TREAT, {
    variables: { id },
  });

  const [createReview] = useMutation<CreateReview>(CREATE_REVIEW, {
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
        <Text>{data.treat.company.name}</Text>
        <Spacer y amount={12} />
        <Container>
          <Chip>
            <Text>{data.treat.category.name} </Text>
          </Chip>
          <Spacer x amount={8} />
          <Chip>
            <Text>{data.treat.subcategory.name}</Text>
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

const ReviewCard = ({ review, score }: GetTreat_treat_reviews) => (
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
  font-family: ${(props) => props.theme.typography.body.fontFamily};
  font-size: ${(props) => props.theme.typography.fontSizes[2]};
  font-weight: ${(props) => props.theme.typography.body.fontWeight};
  color: rgba(255, 255, 255, 1);
  line-height: ${(props) => props.theme.typography.body.fontHeight};
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
