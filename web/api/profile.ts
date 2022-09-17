import {
  getUser,
  supabaseClient,
  supabaseServerClient,
  User,
} from "@supabase/auth-helpers-nextjs";
import { GetServerSidePropsContext, PreviewData } from "next";
import { ParsedUrlQuery } from "querystring";
import { Database } from "../generated/DatabaseDefinitions";

export type Profile = Database["public"]["Tables"]["profiles"]["Row"];

export const search = async (searchTerm: string): Promise<Profile[]> => {
  const { data: profiles, error } = await supabaseClient
    .from("profiles")
    .select()
    .textSearch("fts", searchTerm);

  return error ? [] : profiles;
};

export const getProfileByUsername = async (
  username: string
): Promise<Profile> => {
  const { data: profile, error } = await supabaseClient
    .from("profiles")
    .select("*")
    .eq("username", username)
    .single();

  return error ? null : profile;
};

export const getProfileById = async (id: string): Promise<Profile> => {
  const { data: profile, error } = await supabaseClient
    .from("profiles")
    .select("*")
    .eq("id", id)
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
  profile: Profile;
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

export const deleteCurrentUser = () => supabaseClient.rpc("delete_user");
