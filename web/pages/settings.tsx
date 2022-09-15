import {
  getUser,
  supabaseClient,
  supabaseServerClient,
  User,
  withPageAuth,
} from "@supabase/auth-helpers-nextjs";
import { Block, List, ListButton } from "konsta/react";
import { useRouter } from "next/router";
import Layout from "../components/layout";
import { Database } from "../generated/DatabaseDefinitions";
import { getExportCSVByUsername } from "../utils/export-check-ins";

const deleteMyAccount = async () => {
  await supabaseClient.rpc("delete_user");
};

export default function Settings({
  user,
  profile,
}: {
  user: User;
  profile: Database["public"]["Tables"]["profiles"]["Row"];
}) {
  const router = useRouter();

  return (
    <Layout title="Settings" username={profile.username}>
      <Block strong>{user.email}</Block>

      <List inset>
        <ListButton onClick={() => getExportCSVByUsername(profile.username)}>
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
            deleteMyAccount()
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
    const { user } = await getUser(ctx);
    const { data: profile } = await supabaseServerClient(ctx)
      .from("profiles")
      .select("*")
      .match({ id: user.id })
      .single();

    return { props: { profile, user } };
  },
});
