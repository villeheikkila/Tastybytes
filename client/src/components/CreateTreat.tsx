import React, { useState } from "react";
import styled from "styled-components";
import Input from "./Input";
import { useForm } from "react-hook-form";
import { gql, useMutation, useQuery } from "@apollo/client";
import Combobox, { Item } from "./Combobox";

const CreateTreat: React.FC = () => {
  const { register, handleSubmit } = useForm<{
    name: string;
    producer: string;
  }>();
  const [createTreat] = useMutation(CREATE_TREAT);
  const { data } = useQuery(QUERY_COMPANIES);
  const [selected, setSelected] = useState<Item | null>(null);

  const companies =
    data?.companies.map(({ id, name }: any) => ({
      value: id,
      label: name,
    })) || [];

  const onSubmit = async ({
    name,
    producer,
  }: {
    name: string;
    producer: string;
  }) => {
    if (!selected?.value) return;

    try {
      const response = await createTreat({
        variables: { name, producedBy: parseInt(selected.value) },
      });
      console.log("response: ", response);
    } catch (error) {
      console.error(error);
    }
  };

  return (
    <Container>
      <Form onSubmit={handleSubmit(onSubmit)}>
        <Input
          placeholder="Name"
          name="name"
          ref={register({ required: true })}
        />
        <Combobox items={companies} setSelected={setSelected} />

        <Input type="submit" />
      </Form>
    </Container>
  );
};

const Form = styled.form`
  display: grid;
  grid-gap: 10px;
`;

const CREATE_TREAT = gql`
  mutation CreateTreat($name: String!, $producedBy: Float!) {
    createTreat(name: $name, producedBy: $producedBy) {
      id
    }
  }
`;

const QUERY_COMPANIES = gql`
  query companies {
    companies {
      id
      name
    }
  }
`;

const Container = styled.div`
  display: flex;
  flex-direction: column;
  padding: 10px;
  width: 800px;
  border-radius: 8px;
  background-color: rgba(0, 0, 0, 0.4);

  @media (max-width: 800px) {
    width: calc(100vw - 28px);
  }
`;

export default CreateTreat;
