import { ApolloError } from "@apollo/client";
import { AuthRestrict, SharedLayout } from "@app/components";
import { useForgotPasswordMutation, useSharedQuery } from "@app/graphql";
import { extractError, getCodeFromError } from "@app/lib";
import { NextPage } from "next";
import Link from "next/link";
import React, { useCallback, useState } from "react";
import { useForm } from "react-hook-form";

const ForgotPassword: NextPage = () => {
  const [error, setError] = useState<Error | ApolloError | null>(null);
  const query = useSharedQuery();

  const { register, handleSubmit } = useForm();
  const [forgotPassword] = useForgotPasswordMutation();
  const [successfulEmail, setSuccessfulEmail] = useState<string | null>(null);

  const onSubmit = useCallback(
    (values: any): void => {
      setError(null);
      (async () => {
        try {
          const email = values.email;
          await forgotPassword({
            variables: {
              email,
            },
          });
          // Success: refetch
          setSuccessfulEmail(email);
        } catch (e) {
          setError(e);
        }
      })();
    },
    [forgotPassword, setError]
  );

  const code = getCodeFromError(error);

  if (successfulEmail != null) {
    return (
      <SharedLayout title="Forgot Password" query={query}>
        <div>You've got mail"
          
          We've sent an email reset link to '${successfulEmail}'; click the link and follow the instructions. If you don't receive the link, please ensure you entered the email address correctly, and check in your spam folder just in case.
        </div>
      </SharedLayout>
    );
  }

  return (
    <SharedLayout
      title="Forgot Password"
      query={query}
      forbidWhen={AuthRestrict.LOGGED_IN}
    >
      <form onSubmit={handleSubmit(onSubmit)}>
        <input id="email" placeholder="email" {...register('email', {required: true})} />

        {error ? (
                <span>
                  `Something went wrong`
                  {extractError(error).message}
                  {code ? (
                    <span>
                      {" "}
                      (Error code: <code>ERR_{code}</code>)
                    </span>
                  ) : null}
                </span>
              
        ) : null}
        <div>
          <button type="submit">Reset password</button>
        </div>
        <div>
          <p>
            <Link href="/login">
              <a>Remembered your password? Log in.</a>
            </Link>
          </p>
        </div>
      </form>
    </SharedLayout>
  );
};

export default ForgotPassword;
