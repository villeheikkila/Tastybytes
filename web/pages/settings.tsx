import {
  supabaseClient,
  User,
  withPageAuth,
} from "@supabase/auth-helpers-nextjs";
import {
  Block,
  BlockTitle,
  List,
  ListButton,
  ListInput,
  ListItem,
} from "konsta/react";
import { useRouter } from "next/router";
import { API } from "../api";
import Layout from "../components/layout";
import { Database } from "../generated/DatabaseDefinitions";

export default function Settings({
  user,
  profile,
}: {
  user: User;
  profile: Database["public"]["Tables"]["profiles"]["Row"];
}) {
  const router = useRouter();

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
