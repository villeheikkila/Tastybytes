import React, { FC, useEffect, useState } from "react";
import { useForm } from "react-hook-form";
import { useHistory } from "react-router-dom";
import styled from "styled-components";
import { CategoryPicker, CompanyPicker, SubcategoryPicker } from ".";
import { useModal } from "../../common";
import { Button, HeaderInput, Portal, Sheet } from "../../components";
import { useCreateTreatMutation } from "./queries.hooks";

const AddTreat: FC = () => {
  const history = useHistory();
  const modal = useModal(Sheet);
  const [createTreat] = useCreateTreatMutation();
  const [selected, setSelected] = useState<any>(null);
  const { register, handleSubmit } = useForm<{
    name: string;
  }>();

  useEffect(() => modal.close(), [selected]);

  const onSubmit = handleSubmit(async ({ name }) => {
    try {
      const response = await createTreat({
        variables: {
          name,
          companyId: selected.company.value,
          categoryId: selected.category.id,
          subcategoryId: selected.subcategory.id,
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

          <SelectionButton
            onClick={() =>
              modal.open(
                <CompanyPicker setSelected={setSelected} selected={selected} />
              )
            }
          >
            {!selected?.company ? "Select the company" : selected.company.label}
          </SelectionButton>

          <SelectionButton
            onClick={() =>
              modal.open(
                <CategoryPicker setSelected={setSelected} selected={selected} />
              )
            }
          >
            {!selected?.category
              ? "Select the category"
              : selected["category"].name}
          </SelectionButton>

          <SelectionButton
            onClick={() =>
              modal.open(
                <SubcategoryPicker
                  setSelected={setSelected}
                  selected={selected}
                />
              )
            }
            disabled={!selected?.category?.id}
          >
            {!selected?.subcategory
              ? "Select the subcategory"
              : selected.subcategory.name}
          </SelectionButton>

          <Button type="submit">Submit!</Button>
        </Form>
      </Container>
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
