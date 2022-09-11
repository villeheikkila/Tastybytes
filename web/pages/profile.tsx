import {
  User,
  withPageAuth,
  supabaseServerClient,
  getUser,
} from "@supabase/auth-helpers-nextjs";
import {
  Page,
  Navbar,
  Block,
  Button,
  List,
  ListItem,
  Link,
  BlockTitle,
} from "konsta/react";
import { Database } from "../generated/DatabaseDefinitions";

export default function ProfilePage({
  user,
  data,
}: {
  user: User;
  data: Database["public"]["Tables"]["profiles"]["Row"];
}) {
  console.log("data: ", data);
  return (
    <Page>
      <Navbar title="My App" />

      <Block strong>
        <p>
          Here is your Next.js & Konsta UI app. Let's see what we have here.
        </p>
      </Block>
      <BlockTitle>Navigation</BlockTitle>
      <List>
        <ListItem href="/about/" title="About" />
        <ListItem href="/form/" title="Form" />
      </List>

      <Block strong className="flex space-x-4">
        <Button>Button 1</Button>
        <Button>Button 2</Button>
      </Block>
    </Page>
  );
}

export const getServerSideProps = withPageAuth({
  redirectTo: "/",
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
