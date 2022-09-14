import { supabaseClient } from "@supabase/auth-helpers-nextjs";
import { Block, Card, Link, Page } from "konsta/react";
import { GetServerSideProps } from "next";

const UserProfile = ({ checkIns, summary }: any) => {
  console.log("summary: ", summary);
  return (
    <Page>
      <Block strong inset>
        <span>Total: {summary.totalCheckIns}</span>
      </Block>
      <Block strong inset>
        <span>Unique: {summary.totalUnique}</span>
      </Block>
      <Block strong inset>
        <span>Average: {summary.averageRating}</span>
      </Block>
      <Block>
        {checkIns?.map((c: any) => (
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
};

export const getServerSideProps: GetServerSideProps = async (context) => {
  const username = context.params?.username;
  console.log("username: ", username);

  const { data: profile } = await supabaseClient
    .from("profiles")
    .select("id")
    .eq("username", username)
    .single();

  const { data: checkIns, error } = await supabaseClient
    .from("check_ins")
    .select(
      "id, rating, review, created_at, product_id, profiles (id, username), products (id, name, sub-brands (id, name, brands (id, name, companies (id, name))), subcategories (id, name, categories (id, name)))"
    )
    .limit(10)
    .eq("profiles.username", username);

  const { data: summary, error: summaryError } = await supabaseClient
    .rpc("get_profile_summary", { uid: profile?.id })
    .single();

  return {
    props: {
      checkIns,
      username,
      summary: summary,
    },
  };
};

export default UserProfile;
