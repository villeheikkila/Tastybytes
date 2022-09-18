import {
  supabaseClient,
  User,
  withPageAuth,
} from "@supabase/auth-helpers-nextjs";
import {
  Actions,
  ActionsButton,
  ActionsGroup,
  ActionsLabel,
  BlockTitle,
  List,
  ListButton,
  ListInput,
  ListItem,
  Radio,
} from "konsta/react";
import { useRouter } from "next/router";
import { useState } from "react";
import { API } from "../client";
import { Profile } from "../client/profile";
import Layout from "../components/layout";
import { modifyColorScheme } from "../utils/hooks";

enum Sheets {
  DeleteAccount = "delete-account",
}

export default function Settings({
  user,
  profile: initialProfile,
}: {
  user: User;
  profile: Profile;
}) {
  const router = useRouter();
  const [profile, setProfile] = useState(initialProfile);
  const [email, setEmail] = useState(user.email);
  const [activeSheet, setActiveSheet] = useState<Sheets.DeleteAccount | null>(
    null
  );

  const updateProfile = (update: Partial<Profile>) => {
    API.profiles.update(profile.id, update).then((updatedProfile) => {
      setProfile(updatedProfile);
      modifyColorScheme(updatedProfile.color_scheme);
    });
  };

  const updateEmail = (email: string) => {
    API.profiles.updateEmail(email).then((v) => console.log(v));
  };

  return (
    <Layout title="Settings">
      <BlockTitle>Profile</BlockTitle>

      <List strongIos insetIos>
        <ListInput
          label="First Name"
          type="text"
          placeholder="Your first name"
          value={profile.first_name}
          onChange={(event: any) =>
            setProfile((p) => ({ ...p, first_name: event.target.value }))
          }
          onBlur={(event: any) =>
            updateProfile({ first_name: event.target.value })
          }
        />
        <ListInput
          label="Last Name"
          value={profile.last_name}
          onChange={(event: any) =>
            setProfile((p) => ({ ...p, last_name: event.target.value }))
          }
          type="text"
          placeholder="Your first name"
          onBlur={(event: any) =>
            updateProfile({ last_name: event.target.value })
          }
        />
        <ListInput
          label="Username"
          type="text"
          placeholder="Your first name"
          value={profile.username}
          onChange={(event: any) =>
            setProfile((p) => ({ ...p, username: event.target.value }))
          }
          onBlur={(event: any) =>
            updateProfile({ username: event.target.value })
          }
        />
        <ListInput
          label="Email"
          type="email"
          placeholder="Your e-mail"
          value={email}
          onChange={(event: any) => setEmail(event.target.value)}
          onBlur={(event: any) => updateEmail(event.target.value)}
        />
      </List>

      <BlockTitle>Theme</BlockTitle>
      <List strong inset>
        <ListItem
          label
          title="Light Theme"
          media={
            <Radio
              onChange={() => updateProfile({ color_scheme: "light" })}
              component="div"
              checked={profile.color_scheme === "light"}
            />
          }
        />
        <ListItem
          label
          title="Dark Theme"
          media={
            <Radio
              onChange={() => updateProfile({ color_scheme: "dark" })}
              component="div"
              checked={profile.color_scheme === "dark"}
            />
          }
        />
        <ListItem
          label
          title="System Theme"
          media={
            <Radio
              onChange={() => updateProfile({ color_scheme: "system" })}
              component="div"
              checked={profile.color_scheme === "system"}
            />
          }
        />
      </List>

      <List inset strong>
        <ListButton
          onClick={() => API.checkIns.getExportCSVByUsername(profile.username)}
        >
          Export
        </ListButton>
        <ListButton
          onClick={() =>
            supabaseClient.auth.signOut().then(() => router.push("/login"))
          }
        >
          Sign Out
        </ListButton>
      </List>
      <List inset strong>
        <ListButton onClick={() => setActiveSheet(Sheets.DeleteAccount)}>
          <strong className="text-red-600">Delete Account</strong>
        </ListButton>
      </List>

      <Actions
        opened={activeSheet === Sheets.DeleteAccount}
        onBackdropClick={() => setActiveSheet(null)}
      >
        <ActionsGroup>
          <ActionsLabel>
            Are you sure you want to permanently delete your account? All data
            will be lost.
          </ActionsLabel>
          <ActionsButton
            className="text-red-600"
            onClick={() =>
              API.profiles
                .deleteCurrentUser()
                .then(() => supabaseClient.auth.signOut())
                .then(() => router.push("/login"))
            }
          >
            Delete Account
          </ActionsButton>
          <ActionsButton onClick={() => setActiveSheet(null)} bold>
            Cancel
          </ActionsButton>
        </ActionsGroup>
      </Actions>
    </Layout>
  );
}

export const getServerSideProps = withPageAuth({
  redirectTo: "/login",
  async getServerSideProps(ctx) {
    const props = await API.profiles.gerByContext(ctx);
    return { props };
  },
});
