import React from "react";
import { gql, useLazyQuery } from "@apollo/client";
import { useForm } from "react-hook-form";
import styled from "styled-components";

const Landing = () => {
  const [logIn, { data }] = useLazyQuery<any>(LOGIN);

  console.log("data: ", data);

  const { register, handleSubmit } = useForm();
  const onSubmit = async ({ email, password }: any) => {
    await logIn({
      variables: {
        email,
        password,
      },
    });
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input name="email" ref={register({ required: true })} />
      <input name="password" ref={register({ required: true })} />
      <Input type="submit" />
    </form>
  );
};

const Input = styled.input`
  background-color: gray;
  color: white;
  height: 50px;
  width: 80px;
  border: 1px solid black;
  border-radius: 4px;
`;

const LOGIN = gql`
  query LogIn($email: String!, $password: String!) {
    logIn(email: $email, password: $password)
  }
`;

export default Landing;
