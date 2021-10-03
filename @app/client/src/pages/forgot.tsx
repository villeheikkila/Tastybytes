import { ApolloError } from "@apollo/client";
import {
  AuthRestrict,
  Button,
  ErrorText,
  Input,
  SharedLayout,
} from "@app/components";
import { styled } from "@app/components/src/stitches.config";
import { useForgotPasswordMutation, useSharedQuery } from "@app/graphql";
import { extractError, getCodeFromError } from "@app/lib";
import { ErrorMessage } from "@hookform/error-message";
import { NextPage } from "next";
import Image from "next/image";
import Link from "next/link";
import React, { useState } from "react";
import { useForm } from "react-hook-form";

interface ForgotFormInput {
  email: string;
}

const ForgotPassword: NextPage = () => {
  const [error, setError] = useState<Error | ApolloError | null>(null);
  const query = useSharedQuery();

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<ForgotFormInput>();
  const [forgotPassword] = useForgotPasswordMutation();
  const [successfulEmail, setSuccessfulEmail] = useState<string | null>(null);

  const onSubmit = ({ email }: ForgotFormInput): void => {
    setError(null);
    forgotPassword({
      variables: {
        email,
      },
    })
      .then(() => setSuccessfulEmail(email))
      .catch((e) => setError(e));
  };

  const code = getCodeFromError(error);

  return (
    <SharedLayout
      title="Forgot Password"
      query={query}
      forbidWhen={AuthRestrict.LOGGED_IN}
      hideNavigation
    >
      <Wrapper>
        <Header>
          <Image color="white" src="/maku.svg" height={48} width={48} />

          <h1>Reset password</h1>
        </Header>
        {successfulEmail ? (
          <SuccessMessage>
            <p>
              We've sent an email reset link to {successfulEmail}, click the
              link and follow the instructions. If you don't receive the link,
              please ensure you entered the email address correctly, and check
              in your spam folder just in case.
            </p>
            <Link href="/login">
              <Button>Move back to the login screen</Button>
            </Link>
          </SuccessMessage>
        ) : (
          <Form onSubmit={handleSubmit(onSubmit)}>
            <Input
              id="email"
              autoComplete="email"
              placeholder="Email"
              aria-invalid={errors.email ? "true" : "false"}
              {...register("email", {
                required: true,
                pattern: {
                  value: /\S+@\S+\.\S+/,
                  message: "Entered value does not match email format",
                },
              })}
            />

            <Link href="/login">
              <a>Remembered your password? Log in.</a>
            </Link>

            <div>
              <Button type="submit">Reset password</Button>
            </div>

            <ErrorMessage
              errors={errors}
              name="email"
              render={({ message }) => <ErrorText>{message}</ErrorText>}
            />

            {error ? (
              <ErrorText>
                Something went wrong
                {extractError(error).message}
                {code ? (
                  <>
                    (Error code: <code>ERR_{code}</code>)
                  </>
                ) : null}
              </ErrorText>
            ) : null}
          </Form>
        )}
      </Wrapper>
    </SharedLayout>
  );
};

const Wrapper = styled("div", {
  display: "flex",
  flexDirection: "column",
  gap: "24px",
  width: "400px",
  justifyContent: "center",
  alignItems: "center",
});

const SuccessMessage = styled("div", {
  display: "flex",
  flexDirection: "column",
  gap: "24px",
});

const Form = styled("form", {
  display: "flex",
  flexDirection: "column",
  gap: "12px",
  width: "330px",
});

const Header = styled("header", {
  display: "flex",
  flexDirection: "column",
  justifyContent: "center",
  alignItems: "center",
  gap: "10px",
});

export default ForgotPassword;
