import React from "react";
import { useForm } from "react-hook-form";
import styled from "styled-components";
import { theme } from "../../common";
import {
  Button,
  Container,
  ErrorText,
  Heading,
  Input,
  Link,
  Spacer,
  Typography,
} from "../../components";

import {
  useLogInLazyQuery,
  useRequestAccountVerificationLazyQuery,
} from "./queries.hooks";

const Landing = () => {
  const [logIn, { data }] = useLogInLazyQuery();

  const [requestVerification] = useRequestAccountVerificationLazyQuery();

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
          <Typography>Don't have an account?</Typography>
          <Spacer x amount={4} />
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

          <ErrorText isError={!!data?.logIn}>
            {!!data?.logIn && loginErrors[data.logIn]}
          </ErrorText>

          <Button>Login</Button>
        </Form>
      </Container>
    </Container>
  );
};

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
