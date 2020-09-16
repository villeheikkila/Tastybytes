import React from "react";
import { useParams } from "react-router-dom";
import { gql, useMutation } from "@apollo/client";
import styled from "styled-components";
import { ErrorMessage } from "@hookform/error-message";
import { useForm } from "react-hook-form";
import { PASSWORD_RESET } from "./grapqh";

const PasswordReset = () => {
  const { token }: { token: string } = useParams();
  const [resetPassword] = useMutation(PASSWORD_RESET);
  const { register, handleSubmit, watch, errors } = useForm<{
    password: string;
    passwordCheck: string;
  }>();

  const onSubmit = handleSubmit(async ({ password }) => {
    try {
      const response = await resetPassword({
        variables: {
          token,
          password,
        },
      });
      console.log(response);
    } catch (error) {
      console.error(error);
    }
  });

  return (
    <Container>
      <Header>Reset Password</Header>
      <Form onSubmit={onSubmit}>
        <Label>
          Password
          <Input
            name="password"
            type="password"
            ref={register({
              required: true,
              minLength: {
                value: 6,
                message: `The password must be at least 6 characters long.`,
              },
            })}
          />
          <ErrorMessage
            errors={errors}
            name="password"
            render={({ message }) => <Error>{message}</Error>}
          />
        </Label>

        <Label>
          Confirm Password
          <Input
            name="passwordCheck"
            type="password"
            ref={register({
              validate: (value) =>
                value.length >= 6 && value === watch("password"),
            })}
          />
          <ErrorMessage
            errors={errors}
            name="passwordCheck"
            render={({ message }) => <Error>{message}</Error>}
          />
        </Label>

        <Button type="submit" />
      </Form>
    </Container>
  );
};

const Container = styled.div`
  position: absolute;
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);
`;

const Button = styled.input`
  background-color: rgba(0, 0, 0, 0.4);
  color: rgba(255, 255, 255, 0.847);
  font-size: 24px;
  padding: 5px;
  border: none;
  border-radius: 8px;
  width: 250px;
  outline: none;
  height: 60px;
  margin-top: 20px;

  :focus,
  :hover {
    background-color: rgba(0, 0, 0, 0.8);
  }
`;

const Label = styled.label`
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 400px;
  font-size: 12px;
  text-transform: uppercase;
  font-weight: 700;
`;

const Header = styled.header`
  text-align: center;
  font-size: 28px;
  font-weight: 600;
  margin-bottom: 20px;
`;

const Error = styled.strong``;

const Input = styled.input`
  width: 70%;
  height: 30px;
  border-radius: 6px;
  outline: none;
  border: none;
  padding: 4px;
  margin-top: 4px;
`;

const Form = styled.form`
  display: grid;
  grid-gap: 20px;
  justify-items: center;
  align-items: center;
`;

export default PasswordReset;
