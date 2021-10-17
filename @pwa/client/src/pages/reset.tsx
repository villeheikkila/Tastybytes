import {
  AuthRestrict,
  Button,
  ErrorText,
  Input,
  SharedLayout,
} from "@pwa/components";
import { styled } from "@pwa/components";
import { useResetPasswordMutation, useSharedQuery } from "@pwa/graphql";
import { NextPage } from "next";
import Image from "next/image";
import Link from "next/link";
import React, { useState } from "react";
import { useForm } from "react-hook-form";

enum State {
  PENDING = "PENDING",
  SUBMITTING = "SUBMITTING",
  SUCCESS = "SUCCESS",
}

interface ResetPageProps {
  userId: string | null;
  token: string | null;
}

interface ResetFormValues {
  password: string;
  confirm: string;
}

const ResetPage: NextPage<ResetPageProps> = ({ userId, token }) => {
  const [resetPassword] = useResetPasswordMutation();
  const [error, setError] = useState<Error | null>(null);
  const [state, setState] = useState<State>(State.PENDING);
  const query = useSharedQuery();
  const { register, handleSubmit, watch } = useForm<ResetFormValues>();

  const onSubmit = (values: ResetFormValues) => {
    setState(State.SUBMITTING);
    setError(null);

    if (!!token) {
      (async () => {
        try {
          const result = await resetPassword({
            variables: {
              userId,
              token,
              password: values.password,
            },
          });
          if (result?.data?.resetPassword?.success) {
            setState(State.SUCCESS);
          } else {
            setState(State.PENDING);
            setError(new Error("Incorrect or already used token."));
          }
        } catch (e) {
          if (e.message) {
            setError(e);
          } else {
            setError(new Error("Please check the errors above and try again"));
            console.dir(e);
          }
          setState(State.PENDING);
        }
      })();
    }
  };

  return (
    <SharedLayout
      title="Reset Password"
      query={query}
      forbidWhen={
        // reset is used to change password of OAuth-authenticated users
        AuthRestrict.NEVER
      }
      hideNavigation
    >
      <Wrapper>
        <Header>
          <Image color="white" src="/maku.svg" height={48} width={48} />
          <h1>Reset password</h1>
        </Header>

        <Form
          onSubmit={handleSubmit(onSubmit)}
          css={{ display: state === State.PENDING ? "" : "none" }}
        >
          <Input
            placeholder="Choose a new passphrase:"
            type="password"
            autoComplete="new-password"
            {...register("password")}
          />
          <Input
            type="password"
            placeholder="Confirm passphrase"
            autoComplete="new-password"
            {...register("confirm", {
              required: true,
              validate: (value) =>
                value === watch("password", "") || "The passwords do not match",
            })}
          />
          <Button type="submit">Reset password</Button>
          {error ? (
            <ErrorText onClick={() => setError(null)}>
              {error.message ? String(error.message) : String(error)}
            </ErrorText>
          ) : null}
        </Form>

        {state === "SUBMITTING" ? (
          <Info>Submitting...</Info>
        ) : state === "SUCCESS" ? (
          <Info>
            <p>Your password was reset, you can go and log in now!</p>
            <Link href="/login">
              <Button>Go back to the login screen</Button>
            </Link>
          </Info>
        ) : null}
      </Wrapper>
    </SharedLayout>
  );
};

const Form = styled("form", {
  display: "flex",
  flexDirection: "column",
  gap: "12px",
  width: "380px",
});

const Header = styled("header", {
  display: "flex",
  flexDirection: "column",
  justifyContent: "center",
  alignItems: "center",
  gap: "10px",
});

const Wrapper = styled("div", {
  display: "flex",
  flexDirection: "column",
  gap: "24px",
  width: "400px",
  justifyContent: "center",
  alignItems: "center",
});

const Info = styled("div", {
  display: "flex",
  flexDirection: "column",
  gap: "12px",
});

ResetPage.getInitialProps = async ({ query: { user_id, token } = {} }) => ({
  userId: typeof user_id === "string" ? user_id : null,
  token: typeof token === "string" ? token : null,
});

export default ResetPage;
