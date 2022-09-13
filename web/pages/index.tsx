import {
  getUser,
  supabaseClient,
  supabaseServerClient,
  User,
  withPageAuth,
} from "@supabase/auth-helpers-nextjs";
import { Block, Button, Navbar, Page } from "konsta/react";
import { useRouter } from "next/router";
import { Database } from "../generated/DatabaseDefinitions";
import { getExportCSVByUsername } from "../utils/export-check-ins";

const deleteMyAccount = async () => {
  const response = await supabaseClient.rpc("delete_user");
  console.log("response: ", response);
};

export default function ProfilePage({
  user,
  data,
}: {
  user: User;
  data: Database["public"]["Tables"]["profiles"]["Row"];
}) {
  const router = useRouter();

  return (
    <Page>
      <Navbar title="Profile" />

      <Block strong>{user.email}</Block>

      <Block strong>
        <Button
          large
          onClick={() =>
            supabaseClient.auth.signOut().then(() => router.push("/login"))
          }
        >
          Sign out
        </Button>
        <Button large onClick={() => getExportCSVByUsername(data.username)}>
          Export
        </Button>
        <Button
          large
          onClick={() =>
            deleteMyAccount()
              .then(() => supabaseClient.auth.signOut())
              .then(() => router.push("/login"))
          }
        >
          Delete Account
        </Button>
      </Block>

      <Block></Block>
    </Page>
  );
}

export const getServerSideProps = withPageAuth({
  redirectTo: "/login",
  async getServerSideProps(ctx) {
    const { user } = await getUser(ctx);
    const { data } = await supabaseServerClient(ctx)
      .from("profiles")
      .select("*")
      .match({ id: user.id })
      .limit(1);
    return { props: { data: data?.[0] ?? null } };
  },
});
