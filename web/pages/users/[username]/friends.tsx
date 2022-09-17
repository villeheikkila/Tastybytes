import { User, withPageAuth } from "@supabase/auth-helpers-nextjs";
import { BlockTitle, List, ListInput, ListItem } from "konsta/react";
import { GetServerSideProps } from "next";
import { useEffect, useState } from "react";
import { API } from "../../../api";
import { Profile } from "../../../api/profile";
import Layout from "../../../components/layout";
import { Database } from "../../../generated/DatabaseDefinitions";
import { useDebounce } from "../../../utils/hooks";

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
        {friends?.map((friend) => (
          <ListItem
            key={friend.id}
            link
            header={friend.username}
            title={friend.username}
            footer={friend.username}
            href={`/users/${friend.username}`}
          />
        ))}
      </List>
      <SearchUsers />
    </Layout>
  );
}

const SearchUsers = () => {
  const [searchTerm, setSearchTerm] = useState<string>("");
  const debouncedValue = useDebounce<string>(searchTerm, 500);
  const [profiles, setProfiles] = useState<
    Database["public"]["Tables"]["profiles"]["Row"][]
  >([]);

  useEffect(() => {
    API.profiles.search(debouncedValue).then((p) => setProfiles(p));
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

        {profiles?.map((p) => (
          <ListItem
            key={p.id}
            link
            header={p.username}
            title={p.username}
            footer={p.username}
            href={`/users/${p.username}`}
          />
        ))}
      </List>
    </>
  );
};
export const getServerSideProps: GetServerSideProps = async (ctx) => {
  const username = ctx.params?.username ? String(ctx.params?.username) : null;
  if (!username) throw Error("user doesn't exist");

  const [profile, friends] = await Promise.all([
    API.profiles.getProfileByUsername(username),
    API.friends.getByUsername(username),
  ]);

  return { props: { profile, friends } };
};
