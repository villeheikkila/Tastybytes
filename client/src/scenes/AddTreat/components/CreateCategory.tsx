import React from "react";
import styled from "styled-components";
import { useForm } from "react-hook-form";
import { gql, useMutation } from "@apollo/client";

const CreateCategoryForm: React.FC = () => {
  const { register, handleSubmit } = useForm<{
    name: string;
  }>();
  const [createCategory] = useMutation(CREATE_CATEGORY, {
    refetchQueries: ["Categories"],
  });

  const onSubmit = handleSubmit(async ({ name }) => {
    try {
      await createCategory({
        variables: { name },
      });
    } catch (error) {
      console.error(error);
    }
  });

  return (
    <Form onSubmit={onSubmit}>
      <Input
        placeholder="Add new company"
        name="name"
        ref={register({ required: true })}
      />

      <Button type="submit" value="Add" />
    </Form>
  );
};

const Input = styled.input`
  background-color: rgba(85, 85, 85, 0.8);
  border-top-left-radius: 8px;
  border-bottom-left-radius: 8px;
  display: block;
  border: 1px solid transparent;
  color: rgba(255, 255, 255, 0.847);
  outline: none;
  padding: 5px;
  width: 100%;

  &::placeholder {
    color: rgba(255, 255, 255, 0.247);
  }

  &:focus {
    border-color: rgba(255, 255, 255, 0.247);
  }
`;

const Button = styled.input`
  border: none;
  background-color: rgba(85, 85, 85, 0.8);
  border-top-right-radius: 8px;
  border-bottom-right-radius: 8px;
  border-left: 2px solid rgba(255, 255, 255, 0.247);
`;

const Form = styled.form`
  display: flex;
  margin-bottom: 10px;
`;

const CREATE_CATEGORY = gql`
  mutation CreateCategory($name: String!) {
    createCategory(name: $name) {
      id
    }
  }
`;

export default CreateCategoryForm;
