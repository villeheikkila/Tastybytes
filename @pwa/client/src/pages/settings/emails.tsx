import { ApolloError } from "@apollo/client";
import {
  Button,
  ErrorAlert,
  ErrorText,
  Input,
  Redirect,
  SettingsLayout,
} from "@pwa/components";
import { styled } from "@pwa/common";
import {
  EmailsForm_UserEmailFragment,
  useAddEmailMutation,
  useDeleteEmailMutation,
  useMakeEmailPrimaryMutation,
  useResendEmailVerificationMutation,
  useSettingsEmailsQuery,
} from "@pwa/graphql";
import { extractError, getCodeFromError } from "@pwa/common";
import { ErrorMessage } from "@hookform/error-message";
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
          {email.email}{" "}
          <span
            title={
              email.isVerified
                ? "Verified"
                : "Pending verification (please check your inbox / spam folder"
            }
          >
            {email.isVerified ? "✅" : <ErrorText>(unverified)</ErrorText>}
          </span>
        </span>
        Added ${new Date(Date.parse(email.createdAt)).toLocaleString()}
      </div>
    </div>
  );
};

const Settings_Emails: NextPage = () => {
  const [showAddEmailForm, setShowAddEmailForm] = useState(false);
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
            <p>
              No verified emails You do not have any verified email addresses,
              this will make account recovery impossible and may limit your
              available functionality within this application. Please complete
              email verification.
            </p>
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
            <AddEmailForm onComplete={() => setShowAddEmailForm(false)} />
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
}

interface EmailFormValues {
  email: string;
}

const AddEmailForm = ({ onComplete }: AddEmailFormProps) => {
  const [addEmail] = useAddEmailMutation();

  const {
    register,
    handleSubmit,
    formState: { errors },
    setError,
  } = useForm<EmailFormValues>();

  const onSubmit = async (values: EmailFormValues) => {
    try {
      await addEmail({ variables: { email: values.email } });
      onComplete();
    } catch (e) {
      const errorMessage = extractError(e as ApolloError);
      const errCode = getCodeFromError(e);
      setError("email", {
        message: `${errCode}: Error occured while adding email ${errorMessage.message}`,
      });
    }
  };

  return (
    <Form onSubmit={handleSubmit(onSubmit)}>
      <InputRow>
        <Input
          id="email"
          autoComplete="email"
          placeholder="Email"
          aria-invalid={errors.email ? "true" : "false"}
          {...register("email", {
            required: true,
          })}
        />

        <Button type="submit">Add email</Button>
      </InputRow>
      <ErrorMessage
        errors={errors}
        name="email"
        render={({ message }) => <ErrorText>{message}</ErrorText>}
      />
    </Form>
  );
};

const InputRow = styled("div", {
  display: "flex",
  width: "420px",
  gap: "12px",
});

const Form = styled("form", {
  display: "flex",
  flexDirection: "column",
  gap: "4px",
});
