import { supabaseServerClient } from "@supabase/auth-helpers-nextjs";
import { BlockTitle, List, ListInput, ListItem } from "konsta/react";
import { GetServerSideProps } from "next";
import { useEffect, useState } from "react";
import { API } from "../../../api";
import { Profile } from "../../../api/profile";
import Layout from "../../../components/layout";
import { useDebounce } from "../../../utils/hooks";
import { paths } from "../../../utils/paths";

export default function Friends({
  profile,
  friends,
}: {
  profile: Profile;
  friends: Profile[];
}) {
  return (
    <Layout title="Friends">
      <BlockTitle>{profile.username}</BlockTitle>
      <List>
        {friends.map((friend) => (
          <ListItem
            key={friend.id}
            link
            header={friend.username}
            title={friend.username}
            footer={friend.username}
            href={paths.user.root(friend.username)}
          />
        ))}
      </List>
      <SearchUsers filterIds={[profile.id, ...friends.map(({ id }) => id)]} />
    </Layout>
  );
}

const SearchUsers = ({ filterIds }: { filterIds: string[] }) => {
  const [searchTerm, setSearchTerm] = useState<string>("");
  const debouncedValue = useDebounce<string>(searchTerm, 500);
  const [profiles, setProfiles] = useState<Profile[]>([]);

  useEffect(() => {
    API.profiles
      .search(debouncedValue)
      .then((p) => setProfiles(p.filter(({ id }) => !filterIds.includes(id))));
  }, [debouncedValue]);

  return (
    <>
      <BlockTitle>Search</BlockTitle>
      <List>
        <ListInput
          type="text"
          placeholder="Search..."
          onChange={(v: any) => setSearchTerm(v.target.value)}
        />

        {profiles.map((p) => (
          <ListItem
            key={p.id}
            title={p.username}
            href={paths.user.root(p.username)}
            link
          />
        ))}
      </List>
    </>
  );
};

export const getServerSideProps: GetServerSideProps = async (ctx) => {
  const client = supabaseServerClient(ctx);
  const username = ctx.params?.username ? String(ctx.params?.username) : null;

  if (!username) throw Error("user doesn't exist");

  const [profile, friends] = await Promise.all([
    API.profiles.getProfileByUsername(username, client),
    API.friends.getByUsername(username, client),
  ]);

  return { props: { profile, friends } };
};
