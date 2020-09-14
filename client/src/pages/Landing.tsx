import React from "react";
import { gql, useLazyQuery } from "@apollo/client";
import { useForm } from "react-hook-form";
import styled from "styled-components";
import { LogIn } from "../generated/LogIn";
import { ErrorMessage } from "@hookform/error-message";
import { Link } from "react-router-dom";

const Landing = () => {
  const [logIn] = useLazyQuery<LogIn>(LOGIN);

  const { register, handleSubmit, errors } = useForm<{
    username: string;
    password: string;
  }>();

  const onSubmit = handleSubmit(async (account) => {
    try {
      await logIn({
        variables: {
          account,
        },
      });
    } catch (error) {
      console.error(error);
    }
  });

  return (
    <LogInPage>
      <Content>
        <Form onSubmit={onSubmit}>
          <Label>
            Username
            <Input
              name="username"
              ref={register({
                required: true,
                minLength: {
                  value: 3,
                  message: `The username must be at least 3 characters long.`,
                },
                maxLength: {
                  value: 16,
                  message: `The username can't be over 16 characters long.`,
                },
              })}
            />
            <ErrorMessage
              errors={errors}
              name="username"
              render={({ message }) => <Error>{message}</Error>}
            />
          </Label>

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

          <Button type="submit" />
        </Form>
        <StyledLink to="/signup">Sign Up!</StyledLink>
        <button>Reset Password</button>
      </Content>
    </LogInPage>
  );
};

const LogInPage = styled.div`
  position: absolute;
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);
`;

const Content = styled.div`
  display: flex;
  flex-direction: column;
  justify-items: center;
  align-items: center;
  padding: 10px;
  width: 400px;
  border-radius: 8px;
  background-color: rgba(0, 0, 0, 0.4);
  padding: 30px;

  @media (max-width: 600px) {
    width: 100vw;
  }
`;

const Label = styled.label`
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 100%;
  font-size: 12px;
  text-transform: uppercase;
  font-weight: 700;
`;
const Error = styled.strong`
  color: red;
`;
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
  display: flex;
  flex-direction: column;
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
  margin-bottom: 10px;

  :focus,
  :hover {
    background-color: rgba(0, 0, 0, 0.8);
  }
`;

const StyledLink = styled(Link)`
  background-color: rgba(0, 0, 0, 0.4);
  color: rgba(255, 255, 255, 0.847);
  font-size: 24px;
  padding: 5px;
  border: none;
  border-radius: 8px;
  width: 250px;
  outline: none;
  height: 60px;
  margin-bottom: 10px;
  text-decoration: none;
  text-align: center;

  :focus,
  :hover {
    background-color: rgba(0, 0, 0, 0.8);
  }
`;

const LOGIN = gql`
  query LogIn($account: LogInInput!) {
    logIn(account: $account)
  }
`;

export default Landing;
