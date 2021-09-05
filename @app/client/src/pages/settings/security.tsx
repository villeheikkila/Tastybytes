import { ApolloError } from "@apollo/client";
import { ErrorAlert, SettingsLayout } from "@app/components";
import {
  useChangePasswordMutation,
  useForgotPasswordMutation,
  useSettingsPasswordQuery,
  useSharedQuery,
} from "@app/graphql";
import { extractError, getCodeFromError } from "@app/lib";
import { NextPage } from "next";
import Link from "next/link";
import React, { useCallback, useState } from "react";
import { useForm } from "react-hook-form";

interface PasswordChangeFormValues {
  oldPassword: string
  newPassword: string
}

const Settings_Security: NextPage = () => {
  const { register, handleSubmit, setError: setFormError } = useForm<PasswordChangeFormValues>();
  const [error, setError] = useState<Error | ApolloError | null>(null);
  const query = useSharedQuery();
  const [changePassword] = useChangePasswordMutation();
  const [success, setSuccess] = useState(false);

  const onSubmit = useCallback(
    async (values: PasswordChangeFormValues) => {
      setSuccess(false);
      setError(null);
      try {
        await changePassword({
          variables: {
            oldPassword: values.oldPassword,
            newPassword: values.newPassword,
          },
        });
        setError(null);
        setSuccess(true);
      } catch (e) {
        const errcode = getCodeFromError(e);
        if (errcode === "WEAKP") {
          setFormError("newPassword", {
            message:
              "The server believes this passphrase is too weak, please make it stronger",
          });
        } else if (errcode === "CREDS") {
          setFormError("oldPassword", {
            message: "Incorrect old passphrase",
          });
        } else {
          setError(e);
        }
      }
    },
    [changePassword, setFormError]
  );

  const {
    data,
    error: graphqlQueryError,
    loading,
  } = useSettingsPasswordQuery();
  const [forgotPassword] = useForgotPasswordMutation();
  const u = data && data.currentUser;
  const userEmail = u && u.userEmails.nodes[0];
  const email = userEmail ? userEmail.email : null;
  const [resetInProgress, setResetInProgress] = useState(false);
  const [resetError, setResetError] = useState(null);
  const handleResetPassword = useCallback(() => {
    if (!email) return;
    if (resetInProgress) return;
    (async () => {
      setResetInProgress(true);

      try {
        await forgotPassword({ variables: { email } });
      } catch (e) {
        setResetError(resetError);
      }
      setResetInProgress(false);
    })();
  }, [email, forgotPassword, resetError, resetInProgress]);

  const inner = () => {
    if (loading) {
      /* noop */
    } else if (graphqlQueryError) {
      return <ErrorAlert error={graphqlQueryError} />;
    } else if (data && data.currentUser && !data.currentUser.hasPassword) {
      return (
        <div>
          <h1>Change passphrase</h1>
          <p>
            You registered your account through social login, so you do not
            currently have a passphrase. If you would like a passphrase, press
            the button below to request a passphrase reset email to '{email}'
            (you can choose a different email by making it primary in{" "}
            <Link href="/settings/emails">email settings</Link>).
          </p>
          <button onClick={handleResetPassword} disabled={resetInProgress}>
            Reset passphrase
          </button>
        </div>
      );
    }

    const code = getCodeFromError(error);
    return (
      <div>
        <h1>Change passphrase</h1>
        <form onSubmit={handleSubmit(onSubmit)}>
          <input
            placeholder="Old passphrase"
            id="oldPassword"
            {...register("oldPassword", {
              required: true,
            })}
          />
          <input
            placeholder="New passphrase"
            id="newPassword"
            type="password"
            {...register("newPassword", {
              required: true,
            })}
          />
          {error ? (
            <>
              `Changing passphrase failed`
              <span>
                {extractError(error).message}
                {code ? (
                  <span>
                    {" "}
                    (Error code: <code>ERR_{code}</code>)
                  </span>
                ) : null}
              </span>
            </>
          ) : success ? (
            `Password changed!`
          ) : null}
          <button type="submit">Change Passphrase</button>
        </form>
      </div>
    );
  };
  return (
    <SettingsLayout href="/settings/security" query={query}>
      {inner()}
    </SettingsLayout>
  );
};

export default Settings_Security;
