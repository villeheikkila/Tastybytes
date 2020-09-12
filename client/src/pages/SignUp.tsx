import React from "react";
import { gql, useMutation } from "@apollo/client";
import { useForm } from "react-hook-form";
import styled from "styled-components";
import Card from "../components/Card";

const SignUp = () => {
  const [signUpMutation] = useMutation(CREATE_ACCOUNT);
  const { register, handleSubmit } = useForm<{
    firstName: string;
    lastName: string;
    email: string;
    password: string;
  }>();

  const onSubmit = handleSubmit(async (signUpInput) => {
    await signUpMutation({
      variables: {
        ...signUpInput,
      },
    });
  });

  return (
    <Container>
      <Card>
        <Form onSubmit={onSubmit}>
          <Label>
            First Name:
            <Input name="firstName" ref={register({ required: true })} />
          </Label>

          <Label>
            Last Name:
            <Input name="lastName" ref={register({ required: true })} />
          </Label>

          <Label>
            Email:
            <Input name="email" ref={register({ required: true })} />
          </Label>

          <Label>
            Password:
            <Input name="password" ref={register({ required: true })} />
          </Label>

          <Input type="submit" />
        </Form>
      </Card>
    </Container>
  );
};

const Container = styled.div`
  position: absolute;
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);
`;

const Form = styled.div`
  display: flex;
  flex-direction: column;
  padding: 10px;
`;

const Label = styled.label``;

const Input = styled.input`
  width: 200px;
  border-radius: 6px;
  outline: none;
  border: none;
  padding: 3px;
  margin-bottom: 2px;
`;

const CREATE_ACCOUNT = gql`
  mutation CreateAccount(
    $firstName: String!
    $lastName: String!
    $email: String!
    $password: String!
  ) {
    createAccount(
      firstName: $firstName
      lastName: $lastName
      password: $password
      email: $email
    ) {
      id
    }
  }
`;

export default SignUp;
