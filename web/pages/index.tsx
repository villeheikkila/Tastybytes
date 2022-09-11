import {
  getUser,
  supabaseClient,
  supabaseServerClient,
  User,
  withPageAuth,
} from "@supabase/auth-helpers-nextjs";
import {
  Block,
  BlockTitle,
  Button,
  List,
  ListItem,
  Navbar,
  Page,
} from "konsta/react";
import { useRouter } from "next/router";
import { Database } from "../generated/DatabaseDefinitions";

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
        <div className="flex center-content w-40">
          <Button
            large
            onClick={() =>
              supabaseClient.auth.signOut().then(() => router.push("/login"))
            }
          >
            Sign out
          </Button>
        </div>
      </Block>
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
    return { props: { data: data?.[0] } };
  },
});
