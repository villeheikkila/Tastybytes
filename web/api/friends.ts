import {
  supabaseClient,
  supabaseServerClient,
} from "@supabase/auth-helpers-nextjs";
import { GetServerSidePropsContext, PreviewData } from "next";
import { ParsedUrlQuery } from "querystring";
import { Database } from "../generated/DatabaseDefinitions";

export const acceptFriendRequest = async (
  searchTerm: string
): Promise<Array<Database["public"]["Tables"]["profiles"]["Row"]>> => {
  const { data: profiles, error } = await supabaseClient
    .from("profiles")
    .select()
    .textSearch("fts", searchTerm);

  return error ? [] : profiles;
};

export const getByCtx = async (
  ctx: GetServerSidePropsContext<ParsedUrlQuery, PreviewData>
): Promise<Array<Database["public"]["Tables"]["profiles"]["Row"]> | null> => {
  const { data: friends, error } = await supabaseServerClient(ctx).rpc(
    "get_friends"
  );
  return error ? null : friends;
};
