import { ApolloError } from "@apollo/client";
import {
  AuthRestrict,
  Button,
  ErrorText,
  Input,
  Redirect,
  SharedLayout,
  SharedLayoutChildProps,
} from "@app/components";
import { styled } from "@app/components/src/stitches.config";
import { useLoginMutation, useSharedQuery } from "@app/graphql";
import {
  extractError,
  getCodeFromError,
  Nullable,
  resetWebsocketConnection,
} from "@app/lib";
import { ErrorMessage } from "@hookform/error-message";
import { NextPage } from "next";
import Image from "next/image";
import NextLink from "next/link";
import Router from "next/router";
import React, { useEffect, useState } from "react";
import { useForm } from "react-hook-form";

interface LoginPageProps {
  next: string | null;
}

export const isSafe = (nextUrl: Nullable<string>) => {
  return (nextUrl && nextUrl[0] === "/") || false;
};

const LoginPage: NextPage<LoginPageProps> = ({ next: rawNext }) => {
  const [error, setError] = useState<Error | ApolloError | null>(null);
  const next: string = isSafe(rawNext) ? rawNext! : "/";
  const query = useSharedQuery();
  return (
    <SharedLayout
      title="Sign in"
      query={query}
      forbidWhen={AuthRestrict.LOGGED_IN}
      hideNavigation
    >
      {({ currentUser }: SharedLayoutChildProps) =>
        currentUser ? (
          <Redirect href={next} />
        ) : (
          <Authentication.Wrapper>
            <Authentication.Header>
              <Image color="white" src="/maku.svg" height={48} width={48} />
              <Authentication.H1>Welcome to Maku</Authentication.H1>
              <p>
                Don't have an account?{" "}
                <Link href={`/register?next=${encodeURIComponent(next)}`}>
                  Sign up for free!
                </Link>
              </p>
            </Authentication.Header>

            <div>
              <LoginForm
                onSuccessRedirectTo={next}
                error={error}
                setError={setError}
              />
            </div>
          </Authentication.Wrapper>
        )
      }
    </SharedLayout>
  );
};

LoginPage.getInitialProps = async ({ query }) => ({
  next: typeof query.next === "string" ? query.next : null,
});

export default LoginPage;

interface LoginFormProps {
  onSuccessRedirectTo: string;
  error: Error | ApolloError | null;
  setError: (error: Error | ApolloError | null) => void;
}

interface LoginFormInput {
  username: string;
  password: string;
}

const LoginForm = ({
  onSuccessRedirectTo,
  error,
  setError,
}: LoginFormProps) => {
  const [submitDisabled, setSubmitDisabled] = useState(false);
  const [login, { client }] = useLoginMutation();

  const {
    register,
    handleSubmit,
    formState: { errors },
    setError: setFormError,
    setFocus,
  } = useForm<LoginFormInput>();

  const onSubmit = async (values: LoginFormInput) => {
    setError(null);
    try {
      await login({
        variables: {
          username: values.username,
          password: values.password,
        },
      });
      resetWebsocketConnection();
      client.resetStore();
      Router.push(onSuccessRedirectTo);
    } catch (e) {
      const code = getCodeFromError(e);
      if (code === "CREDS") {
        setFormError("password", {
          message: "Incorrect username or password",
        });
        setSubmitDisabled(false);
      } else {
        setError(e);
      }
    }
  };

  useEffect(() => {
    setFocus("username");
  }, [setFocus]);

  const code = getCodeFromError(error);

  return (
    <Authentication.Form onSubmit={handleSubmit(onSubmit)}>
      <Input
        id="username"
        autoComplete="email username"
        placeholder="E-mail or Username"
        aria-invalid={errors.username ? "true" : "false"}
        {...register("username", { required: true })}
      />

      <Input
        autoComplete="current-password"
        id="password"
        type="password"
        aria-invalid={errors.password ? "true" : "false"}
        placeholder="Password"
        {...register("password", { required: true })}
      />

      <Link as={NextLink} href="/forgot">
        Forgotten password?
      </Link>

      {error ? (
        <span>
          {extractError(error).message}
          {code ? (
            <span>
              (Error code: <code>ERR_{code}</code>)
            </span>
          ) : null}
        </span>
      ) : null}

      <Button type="submit" disabled={submitDisabled}>
        Sign in
      </Button>

      <ErrorMessage
        errors={errors}
        name="password"
        render={({ message }) => <ErrorText>{message}</ErrorText>}
      />
    </Authentication.Form>
  );
};

const Authentication = {
  Wrapper: styled("div", {
    display: "flex",
    flexDirection: "column",
    gap: "16px",
    width: "330px",
  }),
  Header: styled("header", {
    display: "flex",
    flexDirection: "column",
    justifyContent: "center",
    alignItems: "center",
    gap: "10px",
  }),
  H1: styled("h1", { fontSize: "28px" }),
  Form: styled("form", {
    display: "flex",
    flexDirection: "column",
    gap: "10px",
  }),
};

const Link = styled("a", { color: "rgba(0, 153, 254, 1.00)" });
