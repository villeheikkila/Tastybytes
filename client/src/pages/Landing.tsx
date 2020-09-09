import React from "react";
import { gql, useLazyQuery } from "@apollo/client";
import { useForm } from "react-hook-form";
import styled from "styled-components";

const Landing = () => {
  const [logIn] = useLazyQuery<any>(LOGIN);

  const { register, handleSubmit, errors } = useForm<{
    email: string;
    password: string;
  }>();

  const onSubmit = async ({ email, password }: any) => {
    await logIn({
      variables: {
        email,
        password,
      },
    });
  };

  return (
    <LogIn>
      <Form onSubmit={handleSubmit(onSubmit)}>
        <Label htmlFor="email">Email</Label>

        <InputContainer>
          <Input
            type="text"
            id="email"
            name="email"
            aria-invalid={errors.email ? "true" : "false"}
            ref={register({ required: true })}
          />
        </InputContainer>

        <InputContainer>
          <Label htmlFor="password">Password</Label>

          <Input
            type="password"
            id="password"
            name="password"
            aria-invalid={errors.password ? "true" : "false"}
            ref={register({ required: true })}
          />
        </InputContainer>

        <Submit type="submit" />
      </Form>
    </LogIn>
  );
};

const LogIn = styled.div`
  position: absolute;
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);
  width: 300px;
  height: 300px;
  padding: 20px;
  box-shadow: 0 3px 6px rgba(0, 0, 0, 0.16), 0 3px 6px rgba(0, 0, 0, 0.23);
`;

const InputContainer = styled.div`
  position: relative;
  margin-bottom: 25px;
`;

const Label = styled.label``;

const Input = styled.input`
  border: 0;
  border-bottom: 1px solid #555;
  background: transparent;
  width: 100%;
  padding: 8px 0 5px 0;
  font-size: 16px;

  :focus {
    border: none;
    outline: none;
    border-bottom: 1px solid #2196f3;
  }
`;

const Form = styled.form`
  display: flex;
  flex-direction: column;
`;

const Submit = styled.input`
  border: none;
  border-radius: 2px;
  padding: 12px 18px;
  font-size: 16px;
  text-transform: uppercase;
  cursor: pointer;
  color: white;
  background-color: #2196f3;
  box-shadow: 0 0 4px #999;
  outline: none;
  background-position: center;
  transition: background 0.8s;

  :active {
    background-color: #6eb9f7;
    background-size: 100%;
    transition: background 0s;
  }

  :hover {
    background: #47a7f5 radial-gradient(circle, transparent 1%, #47a7f5 1%)
      center/15000%;
  }
`;

const LOGIN = gql`
  query LogIn($email: String!, $password: String!) {
    logIn(email: $email, password: $password)
  }
`;

export default Landing;
