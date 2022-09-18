import { supabaseClient } from "@supabase/auth-helpers-nextjs";
import { Database } from "../generated/DatabaseDefinitions";
import { Profile } from "./profile";

export const acceptFriendRequest = async (
  searchTerm: string
): Promise<Array<Database["public"]["Tables"]["profiles"]["Row"]>> => {
  const { data: profiles, error } = await supabaseClient
    .from("profiles")
    .select()
    .textSearch("fts", searchTerm);

  return error ? [] : profiles;
};

export const getByUsername = async (
  username: string,
  client = supabaseClient
): Promise<Profile[]> => {
  const { data: friends, error } = await client.rpc("get_friends_by_username", {
    p_username: username,
  });
  return error ? [] : friends;
};
