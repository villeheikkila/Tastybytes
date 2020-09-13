import React, { useState } from "react";
import { gql, useMutation } from "@apollo/client";
import { useForm, Controller } from "react-hook-form";
import styled from "styled-components";
import { ErrorMessage } from "@hookform/error-message";
import ReCAPTCHA from "react-google-recaptcha";
import { recaptchaSiteKey } from "..";

const SignUp = () => {
  const [signUpMutation] = useMutation(CREATE_ACCOUNT);
  const { register, handleSubmit, watch, errors, control } = useForm<{
    username: string;
    email: string;
    password: string;
    captchaToken: string;
  }>();

  console.log("errors: ", errors);

  const onSubmit = handleSubmit(
    async ({ password, email, username, captchaToken }) => {
      try {
        await signUpMutation({
          variables: {
            account: { password, email, username, captchaToken },
          },
        });
      } catch (error) {
        console.error(error);
      }
    }
  );

  return (
    <Container>
      <Content>
        <Header>HerQ</Header>
        <Header>Create your Account</Header>
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
            Email
            <Input
              name="email"
              ref={register({
                required: "You need input an email adress.",
                pattern: {
                  value: /^(([^<>()[\]\.,;:\s@\"]+(\.[^<>()[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})$/i,
                  message: "The entered email address is not valid.",
                },
              })}
            />
            <ErrorMessage
              errors={errors}
              name="email"
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
          {recaptchaSiteKey && (
            <Controller
              control={control}
              name="captchaToken"
              render={({ onChange }) => (
                <ReCAPTCHA sitekey={recaptchaSiteKey} onChange={onChange} />
              )}
            />
          )}
          <Button type="submit" />
        </Form>
      </Content>
    </Container>
  );
};

const Container = styled.div`
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

const Header = styled.h1`
  margin: 0;
  padding-bottom: 10px;
`;

const Form = styled.form`
  display: grid;
  grid-gap: 20px;
  width: 100%;
  justify-items: center;
  align-items: center;
`;

const Error = styled.strong`
  color: red;
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

const Input = styled.input`
  width: 70%;
  height: 30px;
  border-radius: 6px;
  outline: none;
  border: none;
  padding: 4px;
  margin-top: 4px;
`;

const CREATE_ACCOUNT = gql`
  mutation CreateAccount($account: AccountInput!) {
    createAccount(account: $account) {
      id
    }
  }
`;

export default SignUp;
