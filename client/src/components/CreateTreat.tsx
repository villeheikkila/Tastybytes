import React, { useState, useEffect } from "react";
import styled from "styled-components";
import Input from "./Input";
import { useForm } from "react-hook-form";
import { gql, useMutation } from "@apollo/client";
import Portal from "./Portal";
import Sheet from "./Sheet";
import Search, { Item } from "./Search";

const CreateTreat: React.FC = () => {
  const { register, handleSubmit } = useForm<{
    name: string;
    producer: string;
  }>();
  const [createTreat] = useMutation(CREATE_TREAT);
  const [selected, setSelected] = useState<Item | null>(null);
  const [showModal, setShowModal] = useState(false);

  useEffect(() => setShowModal(false), [selected]);

  const onSubmit = async ({ name }: { name: string }) => {
    if (!selected?.value) return;

    try {
      await createTreat({
        variables: { name, producedBy: parseInt(selected.value) },
      });
    } catch (error) {
      console.error(error);
    }
  };

  return (
    <>
      <Container>
        <Form onSubmit={handleSubmit(onSubmit)}>
          <HeaderInput
            placeholder="Insert the name"
            name="name"
            ref={register({ required: true })}
          />

          <Button onClick={() => setShowModal(true)}>
            {selected === null ? "Select the producer" : selected.label}
          </Button>

          <Input type="submit" value="Submit" />
        </Form>
      </Container>
      {showModal && (
        <Portal onClose={() => setShowModal(false)}>
          <Sheet onClose={() => setShowModal(false)}>
            <Search setSelected={setSelected} />
          </Sheet>
        </Portal>
      )}
    </>
  );
};

const Button = styled.button`
  border: none;
  outline: none;
  width: 100%;
  text-align: center;
  background-color: inherit;
  color: rgba(255, 255, 255, 0.847);
  border-top: solid 1px rgba(255, 255, 255, 0.247);
  border-bottom: solid 1px rgba(255, 255, 255, 0.247);
  padding: 8px;

  :hover {
    opacity: 0.8;
  }
`;

const HeaderInput = styled.input`
  background-color: inherit;
  color: rgba(255, 255, 255, 0.847);
  font-size: 38px;
  padding: 10px;
  border: none;
  outline: none;
  width: 100%;
  height: 80px;
`;

const Form = styled.form`
  display: grid;
  grid-gap: 20px;
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
  max-width: 600px;
  font-size: 28px;
  border-radius: 8px;

  @media (max-width: 800px) {
    width: calc(100vw);
  }
`;

export default CreateTreat;
