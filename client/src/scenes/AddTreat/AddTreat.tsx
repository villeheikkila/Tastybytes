import React, { useState, useEffect } from "react";
import styled from "styled-components";
import { useForm } from "react-hook-form";
import { useMutation } from "@apollo/client";
import { useHistory } from "react-router-dom";
import SubcategoryPicker from "./components/SubcategoryPicker";
import CompanyPicker from "./components/CompanyPicker";
import CategoryPicker from "./components/CategoryPicker";
import { CreateTreat } from "../../generated/CreateTreat";
import Portal from "../../components/Portal";
import Sheet from "../../components/Sheet";
import { CREATE_TREAT } from "./graphql";
import Button from "../../components/Button";
import HeaderInput from "../../components/HeaderInput";

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

          <SelectionButton onClick={() => setShowModal("COMPANY")}>
            {!selected?.company ? "Select the company" : selected.company.label}
          </SelectionButton>

          <SelectionButton onClick={() => setShowModal("CATEGORY")}>
            {!selected?.category
              ? "Select the category"
              : selected["category"].name}
          </SelectionButton>

          <SelectionButton
            onClick={() => setShowModal("SUBCATEGORY")}
            disabled={!selected?.category?.id}
          >
            {!selected?.subcategory
              ? "Select the subcategory"
              : selected.subcategory.name}
          </SelectionButton>

          <Button type="submit">Submit!</Button>
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

const SelectionButton = styled.button`
  border: none;
  outline: none;
  font-size: 28px;
  text-align: center;
  background-color: inherit;
  color: ${(props) => props.theme.colors.white};
  border-top: solid 1px ${(props) => props.theme.colors.darkGray};
  border-bottom: solid 1px ${(props) => props.theme.colors.darkGray};
  padding: 8px;

  :hover {
    opacity: 0.8;
  }
`;

const Form = styled.form`
  display: grid;
  grid-gap: 20px;
  width: 100%;
`;

const Container = styled.div`
  display: flex;
  flex-direction: column;
  padding: 10px;
  width: 800px;

  @media (max-width: 800px) {
    width: calc(100vw);
  }
`;

export default AddTreat;
