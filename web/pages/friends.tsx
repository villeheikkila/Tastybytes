import {
  getUser,
  supabaseClient,
  supabaseServerClient,
  User,
  withPageAuth,
} from "@supabase/auth-helpers-nextjs";
import { BlockTitle, List, ListInput, ListItem } from "konsta/react";
import { useEffect, useState } from "react";
import Layout from "../components/layout";
import { Database } from "../generated/DatabaseDefinitions";

function useDebounce<T>(value: T, delay?: number): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value);

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delay || 500);

    return () => {
      clearTimeout(timer);
    };
  }, [value, delay]);

  return debouncedValue;
}

export default function Friends({
  user,
  friends,
  profile,
}: {
  user: User;
  profile: Database["public"]["Tables"]["profiles"]["Row"];
  friends: Array<Database["public"]["Tables"]["profiles"]["Row"]>;
}) {
  console.log("friends: ", friends);

  return (
    <Layout title="Friends" username={profile.username}>
      <List>
        {friends.map((friend) => (
          <ListItem
            key={friend.id}
            link
            header={friend.username}
            title={friend.username}
            footer={friend.username}
            href={`/users/${p.username}`}
          />
        ))}
      </List>
      <SearchUsers />
    </Layout>
  );
}

const searchProfiles = async (
  searchTerm: string
): Promise<Array<Database["public"]["Tables"]["profiles"]["Row"]>> => {
  const { data: profiles, error } = await supabaseClient
    .from("profiles")
    .select()
    .textSearch("fts", searchTerm);

  console.log("error: ", error);

  return error ? [] : profiles;
};

const SearchUsers = () => {
  const [searchTerm, setSearchTerm] = useState<string>("");
  const debouncedValue = useDebounce<string>(searchTerm, 500);
  const [profiles, setProfiles] = useState<
    Database["public"]["Tables"]["profiles"]["Row"][]
  >([]);

  useEffect(() => {
    searchProfiles(debouncedValue).then((p) => setProfiles(p));
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
    const { user } = await getUser(ctx);
    const { data: profile } = await supabaseServerClient(ctx)
      .from("profiles")
      .select("*")
      .match({ id: user.id })
      .single();

    const { data: friends } = await supabaseServerClient(ctx).rpc(
      "get_friends"
    );

    return { props: { profile, user, friends } };
  },
});
