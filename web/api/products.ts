import { supabaseClient } from "@supabase/auth-helpers-nextjs";

export interface SearchProduct {
  id: number;
  name: string;
  description: string;
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
}
export const searchProducts = async (
  searchTerm: string
): Promise<SearchProduct[]> => {
  if (searchTerm.length < 3) return [];
  const { data, error } = await supabaseClient
    .rpc("search_products", { p_search_term: `%${searchTerm}%` })
    .select(
      "id, name, description, sub-brands (id, name, brands (id, name, companies (id, name))), subcategories (id, name, categories (id, name))"
    )
    .limit(50);

  return error ? [] : data;
};
