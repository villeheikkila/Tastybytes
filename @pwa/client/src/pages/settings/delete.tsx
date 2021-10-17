import { ApolloError } from "@apollo/client";
import {
  AlertDialog,
  Button,
  ErrorAlert,
  SettingsLayout,
} from "@pwa/components";
import { styled } from "@pwa/common";
import {
  useConfirmAccountDeletionMutation,
  useRequestAccountDeletionMutation,
  useSharedQuery,
} from "@pwa/graphql";
import { NextPage } from "next";
import { useRouter } from "next/router";
import React, { useState } from "react";

const Settings_Accounts: NextPage = () => {
  const query = useSharedQuery();
  const router = useRouter();
  const [error, setError] = useState<Error | ApolloError | null>(null);
  const [confirmOpen, setConfirmOpen] = useState(false);
  const [itIsDone, setItIsDone] = useState(false);
  const [doingIt, setDoingIt] = useState(false);
  const [requestAccountDeletion] = useRequestAccountDeletionMutation();

  const doIt = () => {
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
  };

  const [deleting, setDeleting] = useState(false);
  const [deleted, setDeleted] = useState(false);
  const [confirmAccountDeletion] = useConfirmAccountDeletionMutation();
  const confirmDeletion = () => {
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
  };

  const token: string | null =
    (router && router.query && !Array.isArray(router.query.token)
      ? router.query.token
      : null) || null;

  return (
    <SettingsLayout href="/settings/delete" query={query}>
      <Delete.Wrapper>
        <header>
          <h1>Delete account</h1>
        </header>
        <p>
          Deleting your user account will delete all your data and cannot be
          undone. The products you have added to the database will still remain
          in the service. Make sure you want to do this.
        </p>
        <p>
          To protect your account, we require you to confirm you wish to delete
          your account here, then you will be sent an email with a confirmation
          code (to check your identity) and when you click that link you will be
          asked to confirm your account deletion again.
        </p>
        {token ? (
          <AlertDialog.Root open={!deleted}>
            <AlertDialog.Content>
              <AlertDialog.Title>Confirm account deletion</AlertDialog.Title>
              <AlertDialog.Description>
                This is it.
                <strong>
                  Press this button and your account will be deleted.
                </strong>
                We're sorry to see you go, please don't hesitate to reach out
                and let us know why you no longer want your account.
              </AlertDialog.Description>
              <Flex css={{ justifyContent: "flex-end" }}>
                <AlertDialog.Action asChild>
                  <Button onClick={confirmDeletion}>
                    PERMANENTLY DELETE MY ACCOUNT
                  </Button>
                </AlertDialog.Action>
              </Flex>
            </AlertDialog.Content>
          </AlertDialog.Root>
        ) : itIsDone ? (
          <div>
            Confirm deletion via email link
            <p>
              You've been sent an email with a confirmation link in it, you must
              click it to confirm that you are the account holder so that you
              may continue deleting your account.
            </p>
          </div>
        ) : (
          <AlertDialog.Root>
            <AlertDialog.Trigger asChild>
              <Button onClick={() => setConfirmOpen(true)} variant="warning">
                I want to delete my account
              </Button>
            </AlertDialog.Trigger>
            <AlertDialog.Content>
              <AlertDialog.Title>
                Account deletion confirmation
              </AlertDialog.Title>
              <AlertDialog.Description>
                Before we can delete your account, we need to confirm it's
                definitely you. We'll send you an email with a link in it, which
                when clicked will give you the option to delete your account.
              </AlertDialog.Description>
              <Flex css={{ justifyContent: "flex-end" }}>
                <AlertDialog.Action asChild>
                  <Button>Ok</Button>
                </AlertDialog.Action>
              </Flex>
            </AlertDialog.Content>
          </AlertDialog.Root>
        )}

        <AlertDialog.Root open={confirmOpen}>
          <AlertDialog.Content>
            <AlertDialog.Title>Account deletion confirmation</AlertDialog.Title>
            <AlertDialog.Description>
              Before we can delete your account, we need to confirm it's
              definitely you. We'll send you an email with a link in it, which
              when clicked will give you the option to delete your account.
            </AlertDialog.Description>
            <Flex css={{ justifyContent: "flex-end" }}>
              <AlertDialog.Cancel asChild>
                <Button>Cancel</Button>
              </AlertDialog.Cancel>
              <AlertDialog.Action asChild>
                <Button onClick={doIt} disabled={doingIt}>
                  Permanently delete the account
                </Button>
              </AlertDialog.Action>
            </Flex>
          </AlertDialog.Content>
        </AlertDialog.Root>

        <AlertDialog.Root open={deleted}>
          <AlertDialog.Content>
            <AlertDialog.Title>Farewell!</AlertDialog.Title>
            <AlertDialog.Description>
              Your account has been successfully deleted. We wish you all the
              best.
            </AlertDialog.Description>
            <Flex css={{ justifyContent: "flex-end" }}>
              <AlertDialog.Action asChild>
                <Button
                  onClick={() => {
                    window.location.href = "/";
                  }}
                >
                  Return to homepage
                </Button>
              </AlertDialog.Action>
            </Flex>
          </AlertDialog.Content>
        </AlertDialog.Root>

        {error && <ErrorAlert error={error} />}
      </Delete.Wrapper>
    </SettingsLayout>
  );
};

const Delete = {
  Wrapper: styled("div", {
    display: "flex",
    flexDirection: "column",
    gap: "12px",
  }),
};

const Flex = styled("div", { display: "flex" });
export default Settings_Accounts;
