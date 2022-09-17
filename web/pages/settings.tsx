import {
  supabaseClient,
  User,
  withPageAuth,
} from "@supabase/auth-helpers-nextjs";
import {
  BlockTitle,
  List,
  ListButton,
  ListInput,
  ListItem,
  Radio,
  Toggle,
} from "konsta/react";
import { useRouter } from "next/router";
import { useState } from "react";
import { API } from "../api";
import { Profile } from "../api/profile";
import Layout from "../components/layout";
import { Database } from "../generated/DatabaseDefinitions";

export default function Settings({
  user,
  profile,
}: {
  user: User;
  profile: Profile;
}) {
  const router = useRouter();
  const [theme, setTheme] = useState<
    Database["public"]["Enums"]["color_scheme"]
  >(profile.color_scheme);

  return (
    <Layout title="Settings">
      <BlockTitle>Profile</BlockTitle>

      <List strongIos insetIos>
        <ListInput
          label="First Name"
          type="text"
          placeholder="Your first name"
          value={profile.first_name}
        />
        <ListInput
          label="Last Name"
          type="text"
          placeholder="Your first name"
          value={profile.last_name}
        />
        <ListInput
          label="Username"
          type="text"
          placeholder="Your first name"
          value={profile.username}
        />
        <ListInput
          label="Email"
          type="email"
          placeholder="Your e-mail"
          value={user.email}
        />
      </List>

      <BlockTitle>Theme</BlockTitle>
      <List strong inset>
        <ListItem
          label
          title="Light Theme"
          media={
            <Radio
              onChange={() => setTheme("light")}
              component="div"
              checked={theme === "light"}
            />
          }
        />
        <ListItem
          label
          title="Dark Theme"
          media={
            <Radio
              onChange={() => setTheme("dark")}
              component="div"
              checked={theme === "dark"}
            />
          }
        />
        <ListItem
          label
          title="System Theme"
          media={
            <Radio
              onChange={() => setTheme("system")}
              component="div"
              checked={theme === "system"}
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
        <ListButton
          onClick={() =>
            API.profiles
              .deleteCurrentUser()
              .then(() => supabaseClient.auth.signOut())
              .then(() => router.push("/login"))
          }
        >
          Delete Account
        </ListButton>
      </List>
    </Layout>
  );
}

export const getServerSideProps = withPageAuth({
  redirectTo: "/login",
  async getServerSideProps(ctx) {
    const props = await API.profiles.getUserByCtx(ctx);
    return { props };
  },
});
