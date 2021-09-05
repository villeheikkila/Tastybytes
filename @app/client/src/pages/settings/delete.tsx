import { ApolloError } from "@apollo/client";
import { ErrorAlert, SettingsLayout } from "@app/components";
import {
  useConfirmAccountDeletionMutation,
  useRequestAccountDeletionMutation,
  useSharedQuery,
} from "@app/graphql";
import { getCodeFromError } from "@app/lib";
import { NextPage } from "next";
import { useRouter } from "next/router";
import React, { useCallback, useState } from "react";

const Settings_Accounts: NextPage = () => {
  const router = useRouter();
  const token: string | null =
    (router && router.query && !Array.isArray(router.query.token)
      ? router.query.token
      : null) || null;
  const [error, setError] = useState<Error | ApolloError | null>(null);
  const [confirmOpen, setConfirmOpen] = useState(false);
  const [itIsDone, setItIsDone] = useState(false);
  const [doingIt, setDoingIt] = useState(false);
  const openModal = useCallback(() => setConfirmOpen(true), []);
  const [requestAccountDeletion] = useRequestAccountDeletionMutation();
  const doIt = useCallback(() => {
    setError(null);
    setDoingIt(true);
    (async () => {
      try {
        const result = await requestAccountDeletion();
        if (!result) {
          throw new Error("Result expected");
        }
        const { data, errors } = result;
        if (
          !data ||
          !data.requestAccountDeletion ||
          !data.requestAccountDeletion.success
        ) {
          console.dir(errors);
          throw new Error("Requesting deletion failed");
        }
        setItIsDone(true);
      } catch (e) {
        setError(e);
      }
      setDoingIt(false);
      setConfirmOpen(false);
    })();
  }, [requestAccountDeletion]);
  const [deleting, setDeleting] = useState(false);
  const [deleted, setDeleted] = useState(false);
  const [confirmAccountDeletion] = useConfirmAccountDeletionMutation();
  const confirmDeletion = useCallback(() => {
    if (deleting || !token) {
      return;
    }
    setError(null);
    setDeleting(true);
    (async () => {
      try {
        await confirmAccountDeletion({ variables: { token } });
        // Display confirmation
        setDeleted(true);
      } catch (e) {
        setError(e);
      }
      setDeleting(false);
    })();
  }, [confirmAccountDeletion, deleting, token]);
  const query = useSharedQuery();
  return (
    <SettingsLayout href="/settings/delete" query={query}>
      <h1>Delete account</h1>
      <p>
        Deleting your user account will delete all data (except that which we
        must retain for legal, compliance and accounting reasons) and cannot be
        undone. Make sure you want to do this.
      </p>
      <p>
        To protect your account, we require you to confirm you wish to delete
        your account here, then you will be sent an email with a confirmation
        code (to check your identity) and when you click that link you will be
        asked to confirm your account deletion again.
      </p>
      {token ? (
        <div>
          Confirm account deletion
          <p>
            This is it.
            <strong>Press this button and your account will be deleted.</strong>
            We're sorry to see you go, please don't hesitate to reach out and
            let us know why you no longer want your account.
          </p>
          <button onClick={confirmDeletion} disabled={deleting}>
            PERMANENTLY DELETE MY ACCOUNT
          </button>
        </div>
      ) : itIsDone ? (
        <div>
          Confirm deletion via email link"
          <p>
            You've been sent an email with a confirmation link in it, you must
            click it to confirm that you are the account holder so that you may
            continue deleting your account.
          </p>
        </div>
      ) : (
        <div>
          Delete user account?
          <p>
            Deleting your account cannot be undone, you will lose all your data.
          </p>
          <button onClick={openModal}>I want to delete my account</button>
        </div>
      )}
      {error ? (
        getCodeFromError(error) === "OWNER" ? (
          <div>
            Cannot delete account
            <p>
              You cannot delete your account whilst you are the owner of an
              organization.
            </p>
            <p>
              For each organization you are the owner of, please either assign
              your ownership to another user or delete the organization to
              continue.
            </p>
          </div>
        ) : (
          <ErrorAlert error={error} />
        )
      ) : null}

      <div style={{ visibility: confirmOpen ? "visible" : "hidden" }}>
        "Send delete account confirmation email?"
        <p>
          Before we can delete your account, we need to confirm it's definitely
          you. We'll send you an email with a link in it, which when clicked
          will give you the option to delete your account.
        </p>
        <p>
          You should not trigger this unless you're sure you want to delete your
          account.
        </p>
        <button onClick={doIt}>Return to homepage</button>
      </div>
      <div style={{ visibility: deleted ? "visible" : "hidden" }}>
        <div>
          <button
            onClick={() => {
              window.location.href = "/";
            }}
          >
            Return to homepage
          </button>
        </div>
        Your account has been successfully deleted. We wish you all the best.
      </div>
    </SettingsLayout>
  );
};

export default Settings_Accounts;
