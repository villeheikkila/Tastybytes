import React, { useState, useEffect } from "react";
import styled from "styled-components";
import Input from "../../components/Input";
import { useForm } from "react-hook-form";
import { gql, useMutation } from "@apollo/client";
import { useHistory } from "react-router-dom";
import SubcategoryPicker from "./SubcategoryPicker";
import CompanyPicker from "./CompanyPicker";
import CategoryPicker from "./CategoryPicker";
import { CreateTreat } from "../../generated/CreateTreat";
import Portal from "../../components/Portal";
import Sheet from "../../components/Sheet";

const Modals = {
  CATEGORY: CategoryPicker,
  COMPANY: CompanyPicker,
  SUBCATEGORY: SubcategoryPicker,
};

type ModalsType = keyof typeof Modals;

const AddTreat: React.FC = () => {
  const history = useHistory();
  const [createTreat] = useMutation<CreateTreat>(CREATE_TREAT);
  const [selected, setSelected] = useState<any>(null);
  const [showModal, setShowModal] = useState<ModalsType | null>(null);
  const { register, handleSubmit } = useForm<{
    name: string;
  }>();
  const Modal = showModal && Modals[showModal];

  useEffect(() => setShowModal(null), [selected]);

  const onSubmit = handleSubmit(async ({ name }) => {
    try {
      const response = await createTreat({
        variables: {
          name,
          companyId: parseInt(selected.company.value),
          categoryId: parseInt(selected.category.id),
          subcategoryId: parseInt(selected.subcategory.id),
        },
      });

      history.push(`/treats/add-review/${response?.data?.createTreat.id}`);
    } catch (error) {
      console.error(error);
    }
  });

  return (
    <>
      <Container>
        <Form onSubmit={onSubmit}>
          <HeaderInput
            placeholder="Insert the name"
            name="name"
            ref={register({ required: true })}
          />

          <Button onClick={() => setShowModal("COMPANY")}>
            {!selected?.company ? "Select the company" : selected.company.label}
          </Button>

          <Button onClick={() => setShowModal("CATEGORY")}>
            {!selected?.category
              ? "Select the category"
              : selected["category"].name}
          </Button>

          <Button
            onClick={() => setShowModal("SUBCATEGORY")}
            disabled={!selected?.category?.id}
          >
            {!selected?.subcategory
              ? "Select the subcategory"
              : selected.subcategory.name}
          </Button>

          <Input type="submit" value="Submit" />
        </Form>
      </Container>
      {showModal && Modal && (
        <Portal onClose={() => setShowModal(null)}>
          <Sheet onClose={() => setShowModal(null)}>
            <Modal setSelected={setSelected} selected={selected} />
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
  mutation CreateTreat(
    $name: String!
    $companyId: ID!
    $categoryId: ID!
    $subcategoryId: ID!
  ) {
    createTreat(
      name: $name
      companyId: $companyId
      categoryId: $categoryId
      subcategoryId: $subcategoryId
    ) {
      id
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

export default AddTreat;
