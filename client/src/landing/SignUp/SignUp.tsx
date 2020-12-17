import { ErrorMessage } from "@hookform/error-message";
import React from "react";
import ReCAPTCHA from "react-google-recaptcha";
import { Controller, useForm } from "react-hook-form";
import { useHistory } from "react-router-dom";
import styled from "styled-components";
import { config } from "../../common";
import {
  Button,
  Container,
  ErrorText,
  Heading,
  Input,
  Spacer,
} from "../../components";
import { useCreateAccountMutation } from "./queries.hooks";

const SignUp = () => {
  const history = useHistory();
  const [signUpMutation] = useCreateAccountMutation({
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
            account: {
              password,
              email,
              username,
              captchaToken,
              firstName: "null",
              lastName: "null",
            },
          },
        });
      } catch (error) {
        console.error(error);
      }
    }
  );

  return (
    <Container centeredParent>
      <Container y centered>
        <Heading>Tastekeepr</Heading>
        <Heading tag="h3">Create your Account</Heading>

        <Spacer y amount={40} />

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
              render={({ message }) => <ErrorText>{message}</ErrorText>}
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
              render={({ message }) => <ErrorText>{message}</ErrorText>}
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
              render={({ message }) => <ErrorText>{message}</ErrorText>}
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
              render={({ message }) => <ErrorText>{message}</ErrorText>}
            />
          </InputFieldContainer>

          {config.RECAPTCHA_SITE_KEY && (
            <Controller
              control={control}
              name="captchaToken"
              render={({ onChange }) => (
                <ReCAPTCHA
                  sitekey={config.RECAPTCHA_SITE_KEY}
                  onChange={onChange}
                />
              )}
            />
          )}

          <Button>Sign Up!</Button>
        </Form>
      </Container>
    </Container>
  );
};

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
