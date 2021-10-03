import { ApolloError } from "@apollo/client";
import {
  Button,
  ErrorAlert,
  Input,
  Label,
  Redirect,
  SettingsLayout,
} from "@app/components";
import { styled } from "@app/components/src/stitches.config";
import {
  ProfileSettingsForm_UserFragment,
  useSettingsProfileQuery,
  useUpdateUserMutation,
} from "@app/graphql";
import { extractError, getCodeFromError, Nullable } from "@app/lib";
import { NextPage } from "next";
import React, { useState } from "react";
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

interface ProfileSettingsFormProps {
  user: ProfileSettingsForm_UserFragment;
  error: Error | ApolloError | null;
  setError: (error: Error | ApolloError | null) => void;
}

interface ProfileSettingsFormValues {
  firstName: Nullable<string>;
  lastName: Nullable<string>;
  username: string;
}

function ProfileSettingsForm({
  user,
  error,
  setError,
}: ProfileSettingsFormProps) {
  const [updateUser] = useUpdateUserMutation();
  const [success, setSuccess] = useState(false);

  const {
    register,
    handleSubmit,
    setError: setFormError,
  } = useForm<ProfileSettingsFormValues>({
    defaultValues: {
      firstName: user.firstName,
      lastName: user.lastName,
      username: user.username,
    },
  });

  const onSubmit = async ({
    username,
    firstName,
    lastName,
  }: ProfileSettingsFormValues) => {
    setSuccess(false);
    setError(null);
    try {
      await updateUser({
        variables: {
          id: user.id,
          patch: {
            username,
            firstName,
            lastName,
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
  };

  const code = getCodeFromError(error);

  return (
    <Box>
      <header>
        <h1>Edit profile</h1>
      </header>
      <Form onSubmit={handleSubmit(onSubmit)}>
        <Label>
          First Name
          <Input
            id="firstName"
            placeholder="First Name"
            {...register("firstName", { required: true })}
          />
        </Label>
        <Label>
          Last Name
          <Input
            id="lastName"
            placeholder="Last Name"
            {...register("lastName", { required: true })}
          />
        </Label>
        <Label>
          Username
          <Input
            id="username"
            placeholder="username"
            {...register("username", { required: true })}
          />
        </Label>

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
        <Button type="submit">Update Profile</Button>
      </Form>
    </Box>
  );
}

const Form = styled("form", {
  display: "flex",
  flexDirection: "column",
  gap: "12px",
  width: "400px",
});

const Box = styled("div", {
  display: "flex",
  flexDirection: "column",
  gap: "24px",
});
