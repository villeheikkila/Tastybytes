import React from "react";
import { useLazyQuery } from "@apollo/client";
import { useForm } from "react-hook-form";
import styled from "styled-components";
import { LogIn } from "../generated/LogIn";
import Button from "../components/Button";
import Heading from "../components/Heading";
import Text from "../components/Text";
import Input from "../components/Input";
import { LOGIN } from "./grapqh";
import Link from "../components/Link";
import Spacer from "../components/Spacer";
import Container from "../components/Container";

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

          <Spacer />

          <Button>Login</Button>
        </Form>
      </Container>
    </Container>
  );
};

const Form = styled.form`
  display: grid;
  width: 100%;
  grid-gap: 20px;
  justify-items: center;
  align-items: center;
`;

export default Landing;
