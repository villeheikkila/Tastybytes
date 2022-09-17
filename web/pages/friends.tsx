import { User, withPageAuth } from "@supabase/auth-helpers-nextjs";
import { BlockTitle, List, ListInput, ListItem } from "konsta/react";
import { useEffect, useState } from "react";
import { API } from "../api";
import Layout from "../components/layout";
import { Database } from "../generated/DatabaseDefinitions";
import { useDebounce } from "../utils/hooks";

export default function Friends({
  friends,
  profile,
}: {
  user: User;
  profile: Database["public"]["Tables"]["profiles"]["Row"];
  friends: Array<Database["public"]["Tables"]["profiles"]["Row"]>;
}) {
  return (
    <Layout title="Friends" username={profile.username}>
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
export const getServerSideProps = withPageAuth({
  redirectTo: "/login",
  async getServerSideProps(ctx) {
    const [{ profile, user }, friends] = await Promise.all([
      API.profiles.getUserByCtx(ctx),
      API.friends.getByCtx(ctx),
    ]);

    return { props: { profile, user, friends } };
  },
});
