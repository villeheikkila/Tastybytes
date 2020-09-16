import React from "react";
import { useLazyQuery } from "@apollo/client";
import { useForm } from "react-hook-form";
import styled from "styled-components";
import { LogIn } from "../generated/LogIn";
import { Link as RouterLink } from "react-router-dom";
import Button from "../components/Button";
import Heading from "../components/Heading";
import Text from "../components/Text";
import Input from "../components/Input";
import { LOGIN } from "./grapqh";

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
        <Heading>Welcome to Tastekeeper</Heading>

        <div style={{ height: "8px" }} />

        <Flex>
          <Text>Don't have an account?</Text> <Link to="/signup">Sign up!</Link>
        </Flex>

        <div style={{ height: "40px" }} />

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

          <div />

          <Button>Login</Button>
        </Form>
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
`;

const Flex = styled.div`
  display: flex;
  text-align: center;
  align-items: center;
`;

const Form = styled.form`
  display: grid;
  width: 100%;
  grid-gap: 20px;
  justify-items: center;
  align-items: center;
`;

const Link = styled(RouterLink)`
  color: rgba(255, 255, 255, 0.847);
  outline: none;
  text-decoration: none;
  text-align: center;
  cursor: pointer;
  padding-left: 4px;
  color: #09f;
  font-weight: 600;
`;

export default Landing;
