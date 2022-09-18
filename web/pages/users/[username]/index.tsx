import { supabaseServerClient } from "@supabase/auth-helpers-nextjs";
import { Block } from "konsta/react";
import { GetServerSideProps } from "next";
import Link from "next/link";
import { API } from "../../../api";
import { FetchCheckInsResult } from "../../../api/check-ins";
import { Profile, ProfileSummaryResult } from "../../../api/profile";
import { CheckInsFeed } from "../../../components/check-in-feed";
import Layout from "../../../components/layout";
import { paths } from "../../../utils/paths";

interface UserProfile {
  initialCheckIns: FetchCheckInsResult[];
  summary: ProfileSummaryResult;
  friends: Profile[];
  profile: Profile;
}

const UserProfile = ({
  initialCheckIns,
  friends,
  summary,
  profile,
}: UserProfile) => {
  return (
    <Layout title={profile.username}>
      <Block strong inset>
        <span>Total: {summary.totalCheckIns}</span>
      </Block>
      <Block strong inset>
        <span>Unique: {summary.totalUnique}</span>
      </Block>
      <Block strong inset>
        <span>Average: {summary.averageRating}</span>
      </Block>
      <Block strong inset>
        <Link href={paths.user.friends(profile.username)}>
          <span>Friends ({friends.length})</span>
        </Link>
      </Block>

      <CheckInsFeed
        fetcher={API.checkIns.createFetchById(profile.id)}
        initialCheckIns={initialCheckIns}
      />
    </Layout>
  );
};

export const getServerSideProps: GetServerSideProps = async (ctx) => {
  const client = supabaseServerClient(ctx);
  const username = String(ctx.params?.username);

  const profile = await API.profiles.getByUsername(username);

  const [initialCheckIns, friends, summary] = await Promise.all([
    API.checkIns.createFetchById(profile.id)(0, client),
    API.friends.getByUsername(profile.username, client),
    API.profiles.getSummaryById(profile.id, client),
  ]);

  return {
    props: {
      initialCheckIns,
      summary,
      profile,
      friends,
    },
  };
};

export default UserProfile;
