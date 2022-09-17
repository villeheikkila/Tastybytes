import { User, withPageAuth } from "@supabase/auth-helpers-nextjs";
import { API } from "../api";
import Layout from "../components/layout";
import { Database } from "../generated/DatabaseDefinitions";

export default function Activity({
  profile,
}: {
  user: User;
  profile: Database["public"]["Tables"]["profiles"]["Row"];
}) {
  return <Layout title="Activity" username={profile.username}></Layout>;
}

export const getServerSideProps = withPageAuth({
  redirectTo: "/login",
  async getServerSideProps(ctx) {
    const props = await API.profiles.getUserByCtx(ctx);
    return { props };
  },
});
