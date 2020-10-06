import React from "react";
import { useForm } from "react-hook-form";
import styled from "styled-components";
import Button from "../components/Button";
import Container from "../components/Container";
import Heading from "../components/Heading";
import Input from "../components/Input";
import Link from "../components/Link";
import Spacer from "../components/Spacer";
import Text from "../components/Text";
import { theme } from "../common/theme";
import {
  useLogInLazyQuery,
  useRequestAccountVerificationLazyQuery,
} from "./queries.hooks";

const Landing = () => {
  const [logIn, { data }] = useLogInLazyQuery();

  const [
    requestVerification,
    { data: verificationData },
  ] = useRequestAccountVerificationLazyQuery();

  const { register, handleSubmit, errors, getValues } = useForm<{
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

  // TODO: This works but is kinda messy :D
  const loginErrors = {
    INCORRECT_PASSWORD: "The entered password is invalid",
    UNVERIFIED_ACCOUNT: (
      <>
        You need to verify your account first.{" "}
        <LinkButton
          onClick={(event) => {
            event.preventDefault();
            // TODO: Make this more reliable, currently it would break if user changes the username input
            requestVerification({
              variables: { username: getValues("username") },
            });
          }}
        >
          Request new verification link!
        </LinkButton>
      </>
    ),
    INEXISTENT_ACCOUNT: "Account doesn't exist",
    SUCCESS: "",
  };

  return (
    <Container centeredParent>
      <Container y centered>
        <Heading>Welcome to Tastekeeper</Heading>

        <Spacer y amount={8} />

        <Container centered>
          <Text>Don't have an account?</Text> <Spacer x amount={4} />
          <Link to="/signup">Sign up!</Link>
        </Container>

        <Spacer y amount={40} />

        <Form onSubmit={onSubmit}>
          <Input
            name="username"
            placeholder="Username"
            error={!!errors.username}
            aria-invalid={errors.username ? "true" : "false"}
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

          <Error isError={!!data?.logIn}>
            {!!data?.logIn && loginErrors[data.logIn]}
          </Error>

          <Button>Login</Button>
        </Form>
      </Container>
    </Container>
  );
};

const Error = styled.strong<{ isError: boolean }>`
  color: ${(props) => props.theme.colors.red};
  display: ${(props) => (props.isError ? "block" : "hidden")};
  height: 10px;
`;

const LinkButton = styled.button`
  ${theme.typography.body}
  ${theme.typography.link}
  cursor: grab;
`;

const Form = styled.form`
  display: grid;
  width: 100%;
  grid-gap: 20px;
  justify-items: center;
  align-items: center;
`;

export default Landing;
