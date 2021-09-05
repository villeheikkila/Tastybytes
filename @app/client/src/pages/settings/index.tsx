import { ApolloError } from "@apollo/client";
import { ErrorAlert, Redirect, SettingsLayout } from "@app/components";
import {
  ProfileSettingsForm_UserFragment,
  useSettingsProfileQuery,
  useUpdateUserMutation,
} from "@app/graphql";
import { extractError, getCodeFromError } from "@app/lib";
import { NextPage } from "next";
import React, { useCallback, useState } from "react";
import { useForm } from "react-hook-form";

const Settings_Profile: NextPage = () => {
  const [formError, setFormError] = useState<Error | ApolloError | null>(null);
  const query = useSettingsProfileQuery();
  const { data, loading, error } = query;
  return (
    <SettingsLayout href="/settings" query={query}>
      {data && data.currentUser ? (
        <ProfileSettingsForm
          error={formError}
          setError={setFormError}
          user={data.currentUser}
        />
      ) : loading ? (
        "Loading..."
      ) : error ? (
        <ErrorAlert error={error} />
      ) : (
        <Redirect href={`/login?next=${encodeURIComponent("/settings")}`} />
      )}
    </SettingsLayout>
  );
};

export default Settings_Profile;

/**
 * These are the values in our form
 */
// eslint-disable-next-line @typescript-eslint/no-unused-vars
interface FormValues {
  username: string;
  name: string;
}

interface ProfileSettingsFormProps {
  user: ProfileSettingsForm_UserFragment;
  error: Error | ApolloError | null;
  setError: (error: Error | ApolloError | null) => void;
}

interface ProfileSettingsFormValues {
  name: string | null;
  username: string;
}

function ProfileSettingsForm({
  user,
  error,
  setError,
}: ProfileSettingsFormProps) {
  const {
    register,
    handleSubmit,
    setError: setFormError,
  } = useForm<ProfileSettingsFormValues>({
    defaultValues: {
      name: user.name,
      username: user.username,
    },
  });
  const [updateUser] = useUpdateUserMutation();
  const [success, setSuccess] = useState(false);

  const onSubmit = useCallback(
    async (values: ProfileSettingsFormValues) => {
      setSuccess(false);
      setError(null);
      try {
        await updateUser({
          variables: {
            id: user.id,
            patch: {
              username: values.username,
              name: values.name,
            },
          },
        });
        setError(null);
        setSuccess(true);
      } catch (e) {
        const errcode = getCodeFromError(e);
        if (errcode === "23505") {
          setFormError("username", {
            message:
              "This username is already in use, please pick a different name",
          });
        } else {
          setError(e);
        }
      }
    },
    [setError, updateUser, user.id, setFormError]
  );

  const code = getCodeFromError(error);
  return (
    <div>
      <h1>Edit profile</h1>
      <form onSubmit={handleSubmit(onSubmit)}>
        <input
          id="name"
          placeholder="name"
          {...register("name", { required: true })}
        />
        <input
          id="username"
          placeholder="username"
          {...register("username", { required: true })}
        />

        {error ? (
          <span>
            `Updating username`
            {extractError(error).message}
            {code ? (
              <span>
                {" "}
                (Error code: <code>ERR_{code}</code>)
              </span>
            ) : null}
          </span>
        ) : success ? (
          <span>Profile updated</span>
        ) : null}
        <button type="submit">Update Profile</button>
      </form>
    </div>
  );
}
