import { withPageAuth } from "@supabase/auth-helpers-nextjs";
import { API } from "../api";
import Layout from "../components/layout";
import { Database } from "../generated/DatabaseDefinitions";

export default function Search({
  profile,
}: {
  profile: Database["public"]["Tables"]["profiles"]["Row"];
}) {
  return <Layout title="Search" username={profile.username}></Layout>;
}

export const getServerSideProps = withPageAuth({
  redirectTo: "/login",
  async getServerSideProps(ctx) {
    const props = await API.profiles.getUserByCtx(ctx);
    return { props };
  },
});
