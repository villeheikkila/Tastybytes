import { supabaseClient } from "@supabase/auth-helpers-nextjs";
import { Database } from "../generated/DatabaseDefinitions";
import { downloadCSV } from "../utils/csv";

export type FetchCheckInsResult =
  Database["public"]["Tables"]["check_ins"]["Row"] & {
    profiles: { id: number; username: string };
    products: {
      id: number;
      name: string;
      "sub-brands": {
        id: number;
        name: string;
        brands: {
          id: number;
          name: string;
          companies: { id: number; name: string | null };
        };
      };
      subcategories: {
        id: number;
        name: string;
        categories: { id: number; name: string };
      };
    };
  };

const PAGE_SIZE = 15;

export const fetchPaginated = async (
  createdBy: string,
  page = 0,
  client = supabaseClient
): Promise<FetchCheckInsResult[]> => {
  const firstCheckIn = page * PAGE_SIZE;
  const lastCheckIn = (page + 1) * PAGE_SIZE - 1;

  const { data, error } = await client
    .from("check_ins")
    .select(
      "id, rating, review, created_at, product_id, created_by, profiles (id, username), products (id, name, sub-brands (id, name, brands (id, name, companies (id, name))), subcategories (id, name, categories (id, name)))"
    )
    .range(firstCheckIn, lastCheckIn)
    .eq("created_by", createdBy);

  return error ? [] : data;
};

export const getActivityFeed = async (
  page = 0,
  client = supabaseClient
): Promise<FetchCheckInsResult[]> => {
  const firstCheckIn = page * PAGE_SIZE;
  const lastCheckIn = (page + 1) * PAGE_SIZE - 1;

  const { data, error } = await client
    .rpc("get_activity_feed")
    .select(
      "id, rating, review, created_at, product_id, created_by, profiles (id, username), products (id, name, sub-brands (id, name, brands (id, name, companies (id, name))), subcategories (id, name, categories (id, name)))"
    )
    .range(firstCheckIn, lastCheckIn);

  return error ? [] : data;
};

export const getExportCSVByUsername = async (username: string) => {
  const { data } = await supabaseClient
    .from("csv_export")
    .select("*")
    .eq("username", username)
    .csv();

  if (data) {
    downloadCSV(data);
  }
};
