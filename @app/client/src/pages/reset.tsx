import { AuthRestrict, SharedLayout } from "@app/components";
import { useResetPasswordMutation, useSharedQuery } from "@app/graphql";
import get from "lodash/get";
import { NextPage } from "next";
import React, { useCallback, useState } from "react";
import { useForm } from "react-hook-form";

interface IProps {
  userId: string | null;
  token: string | null;
}

enum State {
  PENDING = "PENDING",
  SUBMITTING = "SUBMITTING",
  SUCCESS = "SUCCESS",
}

interface ResetFormValues {
  token: string;
  password: string;
  confirm: string;
}

const ResetPage: NextPage<IProps> = ({
  userId: rawUserId,
  token: rawToken,
}) => {
  const [error, setError] = useState<Error | null>(null);
  const [state, setState] = useState<State>(State.PENDING);
  const query = useSharedQuery();
  const { register, handleSubmit, watch } = useForm<ResetFormValues>();

  const [[userId, token], setIdAndToken] = useState<[string, string]>([
    rawUserId || "",
    rawToken || "",
  ]);

  const [resetPassword] = useResetPasswordMutation();

  const clearError = useCallback(() => {
    setError(null);
  }, [setError]);

  const onSubmit = useCallback(
    (values: ResetFormValues) => {
      setState(State.SUBMITTING);
      setError(null);
      (async () => {
        try {
          const result = await resetPassword({
            variables: {
              userId,
              token,
              password: values.password,
            },
          });
          if (get(result, "data.resetPassword.success")) {
            setState(State.SUCCESS);
          } else {
            setState(State.PENDING);
            setError(new Error("Incorrect token, please check and try again"));
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
    },
    [resetPassword, token, userId]
  );

  return (
    <SharedLayout
      title="Reset Password"
      query={query}
      forbidWhen={
        // reset is used to change password of OAuth-authenticated users
        AuthRestrict.NEVER
      }
    >
      <div>
        <div>
          <div>
            {state === "SUBMITTING" ? (
              <div>
                type="info" message="Submitting..." description="This might take
                a few moments..."
              </div>
            ) : state === "SUCCESS" ? (
              <div>
                type="success" message="Password Reset" description="Your
                password was reset; you can go and log in now"
              </div>
            ) : null}

            <form
              onSubmit={handleSubmit(onSubmit)}
              style={{ display: state === State.PENDING ? "" : "none" }}
            >
              <input
                placeholder="Enter your reset token:"
                type="text"
                value={token}
                onChange={(e) => setIdAndToken([userId, e.target.value])}
              />
              <input
                placeholder="Choose a new passphrase:"
                type="password"
                autoComplete="new-password"
                {...register("password")}
              />
              <input
                type="password"
                placeholder="Confirm passphrase"
                autoComplete="new-password"
                {...register("confirm", {
                  required: true,
                  validate: (value) =>
                    value === watch("password", "") ||
                    "The passwords do not match",
                })}
              />
              <button type="submit">Reset passphrase</button>
              {error ? (
                <div onClick={clearError}>
                  type="error" closable message=
                  {error.message ? String(error.message) : String(error)}
                </div>
              ) : null}
            </form>
          </div>
        </div>
      </div>
    </SharedLayout>
  );
};

ResetPage.getInitialProps = async ({ query: { user_id, token } = {} }) => ({
  userId: typeof user_id === "string" ? user_id : null,
  token: typeof token === "string" ? token : null,
});

export default ResetPage;
