import { ApolloError } from "@apollo/client";
import {
  AuthRestrict,
  Button,
  Input,
  Redirect,
  SharedLayout,
} from "@pwa/components";
import { styled } from "@pwa/components";
import { useRegisterMutation, useSharedQuery } from "@pwa/graphql";
import {
  extractError,
  getCodeFromError,
  getExceptionFromError,
  resetWebsocketConnection,
} from "@pwa/common";
import { NextPage } from "next";
import Image from "next/image";
import Link from "next/link";
import Router from "next/router";
import React, { useEffect, useState } from "react";
import { useForm } from "react-hook-form";

import { isSafe } from "./login";

interface RegisterProps {
  next: string | null;
}

interface RegisterFormValues {
  firstName: string;
  lastName: string;
  username: string;
  email: string;
  password: string;
  confirm: string;
}

const Register: NextPage<RegisterProps> = ({ next: rawNext }) => {
  const [error, setError] = useState<Error | ApolloError | null>(null);
  const [signUp, { client }] = useRegisterMutation({});
  const query = useSharedQuery();

  const next: string = isSafe(rawNext) ? rawNext! : "/";

  const {
    register,
    handleSubmit,
    setError: setFormError,
    watch,
    formState: { errors },
    setFocus,
  } = useForm<RegisterFormValues>();

  const onSubmit = async ({
    username,
    email,
    password,
    firstName,
    lastName,
  }: RegisterFormValues) => {
    try {
      await signUp({
        variables: {
          username,
          email,
          password,
          firstName,
          lastName,
        },
      });
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
  };

  useEffect(() => {
    setFocus("username");
  }, [setFocus]);

  const code = getCodeFromError(error);

  return (
    <SharedLayout
      title="Register"
      query={query}
      forbidWhen={AuthRestrict.LOGGED_IN}
      hideNavigation
    >
      {({ currentUser }) =>
        currentUser ? (
          <Redirect href={next} />
        ) : (
          <Registration.Wrapper>
            <Registration.Header>
              <Image color="white" src="/maku.svg" height={48} width={48} />
              <Registration.H1>Create Account</Registration.H1>
              <p>
                Already have an account?{" "}
                <Link href={`/login?next=${encodeURIComponent(next)}`}>
                  Sign in!
                </Link>
              </p>
            </Registration.Header>
            <Registration.Form onSubmit={handleSubmit(onSubmit)}>
              <Box>
                <Input
                  autoComplete="given-name"
                  placeholder="First Name"
                  aria-invalid={errors.firstName ? "true" : "false"}
                  {...register("firstName", { required: true })}
                />
                <Input
                  autoComplete="family-name"
                  placeholder="Last Name"
                  aria-invalid={errors.lastName ? "true" : "false"}
                  {...register("lastName", { required: true })}
                />
              </Box>
              <Input
                autoComplete="username"
                placeholder="Username"
                aria-invalid={errors.username ? "true" : "false"}
                {...register("username", {
                  required: true,
                  pattern: {
                    value: /^([a-zA-Z]|$)/,
                    message: "Username must start with a letter.",
                  },
                })}
              />

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
              <Input
                placeholder="Password"
                autoComplete="password"
                aria-invalid={errors.password ? "true" : "false"}
                type="password"
                {...register("password", {
                  required: true,
                  minLength: {
                    value: 8,
                    message: "Password must have at least 8 characters",
                  },
                })}
              />
              <Input
                autoComplete="new-password"
                type="password"
                placeholder="Confirm Password"
                aria-invalid={errors.confirm ? "true" : "false"}
                {...register("confirm", {
                  required: true,
                  validate: (value) =>
                    value === watch("password", "") ||
                    "The passwords do not match",
                })}
              />

              <Button type="submit">Sign up with email</Button>

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
            </Registration.Form>
          </Registration.Wrapper>
        )
      }
    </SharedLayout>
  );
};

Register.getInitialProps = async ({ query }) => ({
  next: typeof query.next === "string" ? query.next : null,
});

const Registration = {
  Wrapper: styled("div", {
    display: "flex",
    flexDirection: "column",
    gap: "16px",
    width: "400px",
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

const Box = styled("div", {
  display: "flex",
  gap: "8px",
});
export default Register;
