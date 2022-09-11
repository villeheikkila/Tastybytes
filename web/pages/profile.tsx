import {
  User,
  withPageAuth,
  supabaseServerClient,
  getUser,
} from "@supabase/auth-helpers-nextjs";
import Title from "@supabase/ui/dist/cjs/components/Typography/Title";

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
    <>
      <div>
        {" "}
        <h1 className="text-3xl font-bold underline">Hello world!</h1>
      </div>
    </>
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
