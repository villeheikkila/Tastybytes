import {
  getUser,
  supabaseClient,
  supabaseServerClient,
  User,
  withPageAuth,
} from "@supabase/auth-helpers-nextjs";
import { Block, Button, Card, Link, Navbar, Page } from "konsta/react";
import { useRouter } from "next/router";
import { useEffect, useState } from "react";
import { Database } from "../generated/DatabaseDefinitions";

const fetchCheckIns = async (username: string) => {
  const { data: checkIns, error } = await supabaseClient
    .from("check_ins")
    .select(
      "id, rating, review, created_at, product_id, profiles (id, username), products (id, name, sub-brands (id, name, brands (id, name, companies (id, name))), subcategories (id, name, categories (id, name)))"
    )
    .eq("profiles.username", username)
    .limit(10);
  return { checkIns, error };
};

export default function ProfilePage({
  user,
  data,
}: {
  user: User;
  data: Database["public"]["Tables"]["profiles"]["Row"];
}) {
  const [checkIns, setCheckIns] = useState<any[] | null>(null);
  console.log("checkIns: ", checkIns?.[0]);
  const c = checkIns?.[0];

  console.log(
    `${c?.products?.["sub-brands"]?.brands?.companies?.name} ${
      c?.products?.["sub-brands"]?.brands?.name
    } ${c?.products?.["sub-brands"]?.name ?? ""} ${c?.products?.name}`
  );

  useEffect(() => {
    fetchCheckIns(data.username).then((values) => setCheckIns(values.checkIns));
  }, []);

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
      </Block>

      <Block>
        {checkIns?.map((c) => (
          <Card
            key={c?.id}
            header={
              <div className="-mx-4 -my-2 h-48 p-4 flex items-end  font-bold bg-cover bg-center">
                {c?.products?.["sub-brands"]?.brands?.companies?.name}{" "}
                {c?.products?.["sub-brands"]?.brands?.name}{" "}
                {c?.products?.["sub-brands"]?.name ?? ""} {c?.products?.name}
              </div>
            }
            footer={
              <div className="flex justify-between">
                <Link>Like</Link>
                <Link>Read more</Link>
              </div>
            }
          >
            <div className="text-gray-500 mb-3">{c?.created_at}</div>
            <p>{c.review}</p>
            <p>{c.rating}</p>
          </Card>
        ))}
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
