import {
  supabaseClient,
  User,
  withPageAuth,
} from "@supabase/auth-helpers-nextjs";
import { Block, List, ListButton } from "konsta/react";
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
      <Block strong>{user.email}</Block>

      <List inset>
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
      <List inset>
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
