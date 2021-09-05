import { ApolloError, useApolloClient } from "@apollo/client";
import {
  AuthRestrict,
  ButtonLink,
  Redirect,
  SharedLayout,
  SharedLayoutChildProps,
  SocialLoginOptions,
} from "@app/components";
import { useLoginMutation, useSharedQuery } from "@app/graphql";
import {
  extractError,
  getCodeFromError,
  resetWebsocketConnection,
} from "@app/lib";
import { NextPage } from "next";
import Link from "next/link";
import Router from "next/router";
import React, { useCallback, useEffect, useRef, useState } from "react";
import { useForm } from "react-hook-form";

interface LoginProps {
  next: string | null;
}

export function isSafe(nextUrl: string | null) {
  return (nextUrl && nextUrl[0] === "/") || false;
}

/**
 * Login page just renders the standard layout and embeds the login form
 */
const Login: NextPage<LoginProps> = ({ next: rawNext }) => {
  const [error, setError] = useState<Error | ApolloError | null>(null);
  const [showLogin, setShowLogin] = useState<boolean>(false);
  const next: string = isSafe(rawNext) ? rawNext! : "/";
  const query = useSharedQuery();
  return (
    <SharedLayout
      title="Sign in"
      query={query}
      forbidWhen={AuthRestrict.LOGGED_IN}
    >
      {({ currentUser }: SharedLayoutChildProps) =>
        currentUser ? (
          <Redirect href={next} />
        ) : (
          <div style={{ marginTop: 32 }}>
            {showLogin ? (
              <div>
                <div>
                  <LoginForm
                    onSuccessRedirectTo={next}
                    onCancel={() => setShowLogin(false)}
                    error={error}
                    setError={setError}
                  />
                </div>
              </div>
            ) : (
              <div>
                <div style={{ marginBottom: 8 }}>
                  <div>
                    <button onClick={() => setShowLogin(true)}>
                      Sign in with E-mail or Username
                    </button>
                  </div>
                </div>
                <div style={{ marginBottom: 8 }}>
                  <div>
                    <SocialLoginOptions next={next} />
                  </div>
                </div>
                <div>
                  <div>
                    <ButtonLink
                      href={`/register?next=${encodeURIComponent(next)}`}
                    >
                      <a>Create an account</a>
                    </ButtonLink>
                  </div>
                </div>
              </div>
            )}
          </div>
        )
      }
    </SharedLayout>
  );
};

Login.getInitialProps = async ({ query }) => ({
  next: typeof query.next === "string" ? query.next : null,
});

export default Login;

interface LoginFormProps {
  onSuccessRedirectTo: string;
  error: Error | ApolloError | null;
  setError: (error: Error | ApolloError | null) => void;
  onCancel: () => void;
}

function LoginForm({
  onSuccessRedirectTo,
  onCancel,
  error,
  setError,
}: LoginFormProps) {
  const {
    register,
    handleSubmit,
    setError: setFormError,
  } = useForm<{ username: string; password: string }>();

  const [login] = useLoginMutation({});
  const client = useApolloClient();

  const [submitDisabled, setSubmitDisabled] = useState(false);
  const onSubmit = useCallback(
    async (values) => {
      console.log("values: ", values);
      setError(null);
      try {
        await login({
          variables: {
            username: values.username,
            password: values.password,
          },
        });
        // Success: refetch
        resetWebsocketConnection();
        client.resetStore();
        Router.push(onSuccessRedirectTo);
      } catch (e) {
        const code = getCodeFromError(e);
        if (code === "CREDS") {
          setFormError("password", {
            message: "Incorrect username or passphrase",
          });
          setSubmitDisabled(true);
        } else {
          setError(e);
        }
      }
    },
    [client, login, setFormError, onSuccessRedirectTo, setError]
  );

  const focusElement = useRef<any>(null);
  useEffect(
    () => void (focusElement.current && focusElement.current!.focus()),
    [focusElement]
  );

  const code = getCodeFromError(error);
  console.log("code: ", code);

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input
        id="username"
        autoComplete="email username"
        placeholder="E-mail or Username"
        {...register("username", { required: true })}
      />
      <input
        autoComplete="current-password"
        id="password"
        type="password"
        placeholder="Passphrase"
        {...register("password", { required: true })}
      />

      <Link href="/forgot">Forgotten passphrase?</Link>

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
      <button type="submit" disabled={submitDisabled}>
        Sign in
      </button>
      <a onClick={onCancel}>Use a different sign in method</a>
    </form>
  );
}
