import React from "react";
import { useMutation } from "@apollo/client";
import { useForm, Controller } from "react-hook-form";
import styled from "styled-components";
import { ErrorMessage } from "@hookform/error-message";
import ReCAPTCHA from "react-google-recaptcha";
import { recaptchaSiteKey } from "..";
import { useHistory } from "react-router-dom";
import Button from "../components/Button";
import Input from "../components/Input";
import Error from "../components/Error";
import Heading from "../components/Heading";
import { CREATE_ACCOUNT } from "./grapqh";

const SignUp = () => {
  const history = useHistory();
  const [signUpMutation] = useMutation(CREATE_ACCOUNT, {
    onCompleted: () => history.push("/email-sent/"),
  });
  const { register, handleSubmit, watch, errors, control } = useForm<{
    username: string;
    email: string;
    password: string;
    passwordCheck: string;
    captchaToken: string;
  }>();

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
        <Heading>Tastekeepr</Heading>
        <Heading>Create your Account</Heading>

        <div style={{ height: "40px" }} />

        <Form onSubmit={onSubmit}>
          <InputFieldContainer>
            <Input
              name="username"
              type="text"
              error={!!errors.username}
              aria-invalid={errors.username ? "true" : "false"}
              placeholder="Username"
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
          </InputFieldContainer>

          <InputFieldContainer>
            <Input
              name="email"
              placeholder="Email"
              error={!!errors.email}
              aria-invalid={errors.email ? "true" : "false"}
              ref={register({
                required: "You need input an email adress.",
                pattern: {
                  //eslint-disable-next-line
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
          </InputFieldContainer>

          <InputFieldContainer>
            <Input
              name="password"
              type="password"
              placeholder="Password"
              error={!!errors.password}
              aria-invalid={errors.password ? "true" : "false"}
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
            />{" "}
          </InputFieldContainer>

          <InputFieldContainer>
            <Input
              name="passwordCheck"
              placeholder="Repeat Password"
              type="password"
              error={!!errors.passwordCheck}
              aria-invalid={errors.passwordCheck ? "true" : "false"}
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
          </InputFieldContainer>

          {recaptchaSiteKey && (
            <Controller
              control={control}
              name="captchaToken"
              render={({ onChange }) => (
                <ReCAPTCHA sitekey={recaptchaSiteKey} onChange={onChange} />
              )}
            />
          )}

          <Button>Sign Up!</Button>
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
`;

const Form = styled.form`
  display: grid;
  grid-gap: 20px;
  width: 100%;
  justify-items: center;
  align-items: center;
`;

const InputFieldContainer = styled.div`
  display: flex;
  flex-direction: column;
  width: 100%;
  align-items: center;
  justify-items: center;
`;

export default SignUp;
