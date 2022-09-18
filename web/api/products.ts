import { supabaseClient } from "@supabase/auth-helpers-nextjs";
import { Database } from "../generated/DatabaseDefinitions";

type Company = Pick<
  Database["public"]["Tables"]["companies"]["Row"],
  "id" | "name"
>;
type Brand = Pick<
  Database["public"]["Tables"]["brands"]["Row"],
  "id" | "name"
> & { companies: Company };

type SubBrand = Pick<
  Database["public"]["Tables"]["sub-brands"]["Row"],
  "id" | "name"
> & { brands: Brand };

type Categories = Pick<
  Database["public"]["Tables"]["categories"]["Row"],
  "id" | "name"
>;

type Subcategories = Pick<
  Database["public"]["Tables"]["sub-brands"]["Row"],
  "id" | "name"
> & { categories: Categories };

export interface ProductJoined {
  id: number;
  name: string;
  description: string;
  "sub-brands": SubBrand;
  subcategories: Subcategories;
}
export const search = async (searchTerm: string): Promise<ProductJoined[]> => {
  if (searchTerm.length < 3) return [];
  const { data, error } = await supabaseClient
    .rpc("search_products", { p_search_term: `%${searchTerm}%` })
    .select(
      "id, name, description, sub-brands (id, name, brands (id, name, companies (id, name))), subcategories (id, name, categories (id, name))"
    )
    .limit(50);

  return error ? [] : data;
};

export const getById = async (id: number): Promise<ProductJoined[]> => {
  const { data, error } = await supabaseClient
    .from("products")
    .select(
      "id, name, description, sub-brands (id, name, brands (id, name, companies (id, name))), subcategories (id, name, categories (id, name))"
    )
    .eq("id", id)
    .single();

  return error ? [] : data;
};
