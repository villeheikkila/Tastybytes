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

export const getByUsername = async (
  username: string,
  client = supabaseClient
): Promise<Profile> => {
  const { data: profile, error } = await client
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

export const getSummaryById = async (
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

export const gerByContext = async (
  ctx: GetServerSidePropsContext<ParsedUrlQuery, PreviewData>
): Promise<UserByCtxReturn> => {
  const { user } = await getUser(ctx);
  const { data: profile } = await supabaseServerClient(ctx)
    .from("profiles")
    .select("*")
    .match({ id: user.id })
    .single();

  return { user, profile };
};

export const update = async (
  userId: string,
  updatedUser: Partial<Omit<Profile, "fts">>
): Promise<Profile> => {
  const { data: profile } = await supabaseClient
    .from("profiles")
    .update(updatedUser, { returning: "representation" })
    .match({ id: userId })
    .single();

  return profile;
};

export const updateEmail = async (email: string) => {
  return await supabaseClient.auth.update({
    email,
  });
};

export const deleteCurrentUser = () => supabaseClient.rpc("delete_user");
