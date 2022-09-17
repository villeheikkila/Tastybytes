import { supabaseServerClient } from "@supabase/auth-helpers-nextjs";
import { Block, Card, Link } from "konsta/react";
import { GetServerSideProps } from "next";
import { useEffect, useRef, useState } from "react";
import { API } from "../../api";
import { FetchCheckInsResult } from "../../api/check-ins";
import { ProfileSummaryResult } from "../../api/profile";
import Layout from "../../components/layout";
import { Database } from "../../generated/DatabaseDefinitions";
import { useInView } from "../../utils/hooks";

interface UserProfile {
  initialCheckIns: FetchCheckInsResult[];
  summary: ProfileSummaryResult;
  profile: Database["public"]["Tables"]["profiles"]["Row"];
}

const UserProfile = ({ initialCheckIns, summary, profile }: UserProfile) => {
  const [checkIns, setCheckIns] = useState(initialCheckIns);
  const [page, setPage] = useState(1);
  const ref = useRef<HTMLDivElement | null>(null);
  const inView = useInView(ref);

  useEffect(() => {
    API.checkIns.fetchPaginated(profile.id, page).then((d) => {
      setCheckIns(checkIns.concat(d));
      setPage((p) => p + 1);
    });
  }, [inView, profile.id]);

  return (
    <Layout title={profile.username} username={profile.username}>
      <Block strong inset>
        <span>Total: {summary.totalCheckIns}</span>
      </Block>
      <Block strong inset>
        <span>Unique: {summary.totalUnique}</span>
      </Block>
      <Block strong inset>
        <span>Average: {summary.averageRating}</span>
      </Block>
      <Block
        style={{
          height: "100vh",
        }}
      >
        {checkIns.map((checkIn) => (
          <Card
            key={checkIn.id}
            header={
              <div className="-mx-4 -my-2 h-48 p-4 flex items-end  font-bold bg-cover bg-center">
                {checkIn.products["sub-brands"].brands.companies.name}{" "}
                {checkIn.products["sub-brands"].brands.name}{" "}
                {checkIn.products["sub-brands"].name ?? ""}{" "}
                {checkIn.products.name}
              </div>
            }
            footer={
              <div className="flex justify-between">
                <Link>Like</Link>
              </div>
            }
          >
            <div className="text-gray-500 mb-3">{checkIn.created_at}</div>
            <p>{checkIn.review}</p>
            <p>{checkIn.rating}</p>
          </Card>
        ))}
        <div ref={ref}>Loading...</div>
      </Block>
    </Layout>
  );
};

export const getServerSideProps: GetServerSideProps = async (ctx) => {
  const client = supabaseServerClient(ctx);
  const username = ctx.params?.username ? String(ctx.params?.username) : null;

  if (!username) throw Error("user doesn't exist");

  const profile = await API.profiles.getProfileByUsername(username);
  const [initialCheckIns, summary] = await Promise.all([
    API.checkIns.fetchPaginated(profile.id, 0, client),
    API.profiles.getProfileSummaryById(profile.id, client),
  ]);

  return {
    props: {
      initialCheckIns,
      summary,
      profile,
    },
  };
};

export default UserProfile;
