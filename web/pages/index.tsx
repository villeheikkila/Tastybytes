import { withPageAuth } from "@supabase/auth-helpers-nextjs";
import Layout from "../components/layout";

export default function Activity() {
  return <Layout title="Activity"></Layout>;
}

export const getServerSideProps = withPageAuth({
  redirectTo: "/login",
});
