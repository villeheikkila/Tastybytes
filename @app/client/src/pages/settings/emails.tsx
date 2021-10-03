import { ApolloError } from "@apollo/client";
import { Button, ErrorAlert, Redirect, SettingsLayout } from "@app/components";
import {
  EmailsForm_UserEmailFragment,
  useAddEmailMutation,
  useDeleteEmailMutation,
  useMakeEmailPrimaryMutation,
  useResendEmailVerificationMutation,
  useSettingsEmailsQuery,
} from "@app/graphql";
import { extractError, getCodeFromError } from "@app/lib";
import { NextPage } from "next";
import React, { useState } from "react";
import { useForm } from "react-hook-form";

const Email = ({
  email,
  hasOtherEmails,
}: {
  email: EmailsForm_UserEmailFragment;
  hasOtherEmails: boolean;
}) => {
  const [deleteEmail] = useDeleteEmailMutation();
  const [resendEmailVerification] = useResendEmailVerificationMutation();
  const [makeEmailPrimary] = useMakeEmailPrimaryMutation();

  const canDelete = !email.isPrimary && hasOtherEmails;

  return (
    <div>
      {[
        email.isPrimary && <span>Primary</span>,
        canDelete && (
          <a
            key={email.id}
            onClick={() => deleteEmail({ variables: { emailId: email.id } })}
          >
            Delete
          </a>
        ),
        !email.isVerified && (
          <a
            key={email.id}
            onClick={() =>
              resendEmailVerification({ variables: { emailId: email.id } })
            }
          >
            Resend verification
          </a>
        ),
        email.isVerified && !email.isPrimary && (
          <a
            key={email.id}
            onClick={() =>
              makeEmailPrimary({ variables: { emailId: email.id } })
            }
          >
            Make primary
          </a>
        ),
      ].filter((_) => _)}
      <div>
        <span>
          {" "}
          {email.email}{" "}
          <span
            title={
              email.isVerified
                ? "Verified"
                : "Pending verification (please check your inbox / spam folder"
            }
          >
            {email.isVerified ? (
              "✅"
            ) : (
              <small style={{ color: "red" }}>(unverified)</small>
            )}
          </span>
        </span>
        Added ${new Date(Date.parse(email.createdAt)).toLocaleString()}
      </div>
    </div>
  );
};

const Settings_Emails: NextPage = () => {
  const [showAddEmailForm, setShowAddEmailForm] = useState(false);
  const [formError, setFormError] = useState<Error | ApolloError | null>(null);
  const query = useSettingsEmailsQuery();
  const { data, loading, error } = query;
  const user = data && data.currentUser;
  const pageContent = (() => {
    if (error && !loading) {
      return <ErrorAlert error={error} />;
    } else if (!user && !loading) {
      return (
        <Redirect
          href={`/login?next=${encodeURIComponent("/settings/emails")}`}
        />
      );
    } else if (!user) {
      return "Loading";
    } else {
      return (
        <div>
          <header>
            <h1>Email addresses</h1>
          </header>
          {user.isVerified ? null : (
            <div>
              No verified emails You do not have any verified email addresses,
              this will make account recovery impossible and may limit your
              available functionality within this application. Please complete
              email verification.
            </div>
          )}
          <p>
            <strong>
              Account notices will be sent your primary email address.
            </strong>{" "}
            Additional email addresses may be added to help with account
            recovery (or to change your primary email), but they cannot be used
            until verified.
          </p>
          {user.userEmails.nodes.map((email) => (
            <Email
              key={email.id}
              email={email}
              hasOtherEmails={user.userEmails.nodes.length > 1}
            />
          ))}
          {!showAddEmailForm ? (
            <div>
              <Button onClick={() => setShowAddEmailForm(true)}>
                Add email
              </Button>
            </div>
          ) : (
            <AddEmailForm
              onComplete={() => setShowAddEmailForm(false)}
              error={formError}
              setError={setFormError}
            />
          )}
        </div>
      );
    }
  })();
  return (
    <SettingsLayout href="/settings/emails" query={query}>
      {pageContent}
    </SettingsLayout>
  );
};

export default Settings_Emails;

interface AddEmailFormProps {
  onComplete: () => void;
  error: Error | ApolloError | null;
  setError: (error: Error | ApolloError | null) => void;
}

interface EmailFormValues {
  email: string;
}

const AddEmailForm = ({ error, setError, onComplete }: AddEmailFormProps) => {
  const { register, handleSubmit } = useForm<EmailFormValues>();
  const [addEmail] = useAddEmailMutation();

  const onSubmit = async (values: EmailFormValues) => {
    try {
      setError(null);
      await addEmail({ variables: { email: values.email } });
      onComplete();
    } catch (e) {
      setError(e);
    }
  };

  const code = getCodeFromError(error);

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input
        id="email"
        {...register("email", {
          required: true,
        })}
      />

      {error ? (
        <div>
          Error adding email
          <span>
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

      <button type="submit">Add email</button>
    </form>
  );
};
