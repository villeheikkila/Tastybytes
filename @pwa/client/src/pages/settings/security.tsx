import { ApolloError } from "@apollo/client";
import {
  Button,
  ErrorAlert,
  Input,
  Label,
  SettingsLayout,
} from "@pwa/components";
import { styled } from "@pwa/components";
import {
  useChangePasswordMutation,
  useForgotPasswordMutation,
  useSettingsPasswordQuery,
  useSharedQuery,
} from "@pwa/graphql";
import { extractError, getCodeFromError } from "@pwa/common";
import { NextPage } from "next";
import Link from "next/link";
import React, { useState } from "react";
import { useForm } from "react-hook-form";

interface PasswordChangeFormValues {
  oldPassword: string;
  newPassword: string;
}

const Settings_Security: NextPage = () => {
  const query = useSharedQuery();
  const [error, setError] = useState<Error | ApolloError | null>(null);
  const [changePassword] = useChangePasswordMutation();
  const [success, setSuccess] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors },
    setError: setFormError,
  } = useForm<PasswordChangeFormValues>();

  const onSubmit = async (values: PasswordChangeFormValues) => {
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
  };

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

  const handleResetPassword = () => {
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
  };

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
      <Security.Container>
        <header>
          <h1>Change password</h1>
        </header>
        <Security.Form onSubmit={handleSubmit(onSubmit)}>
          <Label>
            Current Password
            <Input
              placeholder="Old passphrase"
              autoComplete="password"
              aria-invalid={errors.oldPassword ? "true" : "false"}
              id="oldPassword"
              {...register("oldPassword", {
                required: true,
              })}
            />
          </Label>
          <Label>
            New Password
            <Input
              placeholder="New password"
              id="newPassword"
              autoComplete="new-password"
              type="password"
              aria-invalid={errors.newPassword ? "true" : "false"}
              {...register("newPassword", {
                required: true,
              })}
            />
          </Label>

          <Button type="submit">Change Passphrase</Button>
        </Security.Form>
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
      </Security.Container>
    );
  };
  return (
    <SettingsLayout href="/settings/security" query={query}>
      {inner()}
    </SettingsLayout>
  );
};

const Security = {
  Container: styled("div", {
    display: "flex",
    flexDirection: "column",
    gap: "24px",
  }),
  Form: styled("form", {
    display: "flex",
    flexDirection: "column",
    gap: "12px",
  }),
};

export default Settings_Security;
