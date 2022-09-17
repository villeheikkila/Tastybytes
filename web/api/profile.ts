import {
  getUser,
  supabaseClient,
  supabaseServerClient,
  User,
} from "@supabase/auth-helpers-nextjs";
import { GetServerSidePropsContext, PreviewData } from "next";
import { ParsedUrlQuery } from "querystring";
import { Database } from "../generated/DatabaseDefinitions";

export const search = async (
  searchTerm: string
): Promise<Array<Database["public"]["Tables"]["profiles"]["Row"]>> => {
  const { data: profiles, error } = await supabaseClient
    .from("profiles")
    .select()
    .textSearch("fts", searchTerm);

  return error ? [] : profiles;
};

export const getProfileByUsername = async (
  username: string
): Promise<Database["public"]["Tables"]["profiles"]["Row"]> => {
  const { data: profile, error } = await supabaseClient
    .from("profiles")
    .select("id")
    .eq("username", username)
    .single();

  return error ? null : profile;
};

export type ProfileSummaryResult = {
  totalCheckIns: number;
  totalUnique: number;
  averageRating: number;
};

export const getProfileSummaryById = async (
  uid: string,
  client = supabaseClient
): Promise<ProfileSummaryResult | null> => {
  const { data: summary, error } = await client
    .rpc("get_profile_summary", { uid: uid })
    .single();

  return error ? null : summary;
};

export type UserByCtxReturn = {
  user: User;
  profile: Database["public"]["Tables"]["profiles"]["Row"];
};
export const getUserByCtx = async (
  ctx: GetServerSidePropsContext<ParsedUrlQuery, PreviewData>
): Promise<UserByCtxReturn> => {
  const { user } = await getUser(ctx);
  const { data: profile } = await supabaseServerClient(ctx)
    .from("profiles")
    .select("*")
    .match({ id: user.id })
    .single();

  return { user, profile: profile };
};

export const deleteCurrentUserAccount = () => supabaseClient.rpc("delete_user");
