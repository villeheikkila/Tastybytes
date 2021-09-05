import { ApolloError, useApolloClient } from "@apollo/client";
import { AuthRestrict, Redirect, SharedLayout } from "@app/components";
import { useRegisterMutation, useSharedQuery } from "@app/graphql";
import {
  extractError,
  getCodeFromError,
  getExceptionFromError,
  resetWebsocketConnection,
} from "@app/lib";
import { NextPage } from "next";
import Router from "next/router";
import React, { useCallback, useState } from "react";
import { useForm } from "react-hook-form";

import { isSafe } from "./login";

interface RegisterProps {
  next: string | null;
}

interface RegisterFormValues {
  name: string,
  username: string,
  email: string,
  password: string,
  confirm: string
}
/**
 * The registration page just renders the standard layout and embeds the
 * registration form.
 */
const Register: NextPage<RegisterProps> = ({ next: rawNext }) => {
  const [error, setError] = useState<Error | ApolloError | null>(null);
  const next: string = isSafe(rawNext) ? rawNext! : "/";
  const query = useSharedQuery();

  const [signUp] = useRegisterMutation({});
  const client = useApolloClient();
  const { register, handleSubmit, setError: setFormError, watch } = useForm<RegisterFormValues>();

  const onSubmit = useCallback(
    async (values: RegisterFormValues) => {
      try {
        await signUp({
          variables: {
            username: values.username,
            email: values.email,
            password: values.password,
            name: values.name,
          },
        });
        // Success: refetch
        resetWebsocketConnection();
        client.resetStore();
        Router.push(next);
      } catch (e) {
        const code = getCodeFromError(e);
        const exception = getExceptionFromError(e);
        const fields: any = exception && exception["fields"];
        if (code === "WEAKP") {
          setFormError("password", {
            message:
              "The server believes this passphrase is too weak, please make it stronger",
          });
        } else if (code === "EMTKN") {
          setFormError("email", {
            message:
              "An account with this email address has already been registered, consider using the 'Forgot passphrase' function.",
          });
        } else if (code === "NUNIQ" && fields === "username") {
          setFormError("username", {
            message:
              "An account with this username has already been registered, please try a different username.",
          });
        } else if (code === "23514") {
          setFormError("username", {
            message:
              "This username is not allowed; usernames must be between 2 and 24 characters long (inclusive), must start with a letter, and must contain only alphanumeric characters and underscores.",
          });
        } else {
          setError(e);
        }
      }
    },
    [setFormError, signUp, client, next]
  );

  const code = getCodeFromError(error);
  return (
    <SharedLayout
      title="Register"
      query={query}
      forbidWhen={AuthRestrict.LOGGED_IN}
    >
      {({ currentUser }) =>
        currentUser ? (
          <Redirect href={next} />
        ) : (
          <form onSubmit={handleSubmit(onSubmit)}>
            <input
              autoComplete="name"
              placeholder="name"
              {...register("name", { required: true })}
            />
            <input
              autoComplete="username"
              placeholder="username"
              {...register("username", {
                required: true,
                pattern: {
                  value: /^([a-zA-Z]|$)/,
                  message: "Username must start with a letter.",
                },
              })}
            />
            <input
              id="email"
              autoComplete="email"
              placeholder="email"
              {...register("email", {
                required: true,
                pattern: {
                  value: /\S+@\S+\.\S+/,
                  message: "Entered value does not match email format",
                },
              })}
            />

            {/* //   min: 2,
            //   message: "Username must be at least 2 characters long.",
            // },
            // {
            //   max: 24,
            //   message: "Username must be no more than 24 characters long.",
            // },

            // {
            //   pattern: /^([^_]|_[^_]|_$)*$/,
            //   message:
            //     "Username must not contain two underscores next to each other.",
            // },
            // {
            //   pattern: /^[a-zA-Z0-9_]*$/,
            //   message:
            //     "Username must contain only alphanumeric characters and underscores.",
            // }})}  */}
            <input
              placeholder="password"
              autoComplete="password"
              type="password"
              {...register("password", { required: true,           minLength: {
                value: 8,
                message: "Password must have at least 8 characters"
              }})}
            />
            <input
              autoComplete="new-password"
              type="password"
              placeholder="confirm password"
              {...register("confirm", { required: true, validate: value =>
                value === watch("password", "") || "The passwords do not match"})}
            />

            {error ? (
              <div>
                <span>
                  Registration failed
                  {extractError(error).message}
                  {code ? (
                    <span>
                      {" "}
                      (Error code: <code>ERR_{code}</code>)
                    </span>
                  ) : null}
                </span>
              </div>
            ) : null}
            <div>
              <button type="submit">Register</button>
            </div>
          </form>
        )
      }
    </SharedLayout>
  );
};

Register.getInitialProps = async ({ query }) => ({
  next: typeof query.next === "string" ? query.next : null,
});

export default Register;
