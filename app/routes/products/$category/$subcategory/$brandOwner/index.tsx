import type { ActionFunction, LoaderFunction } from "@remix-run/node";
import { json, redirect } from "@remix-run/node";
import { useCatch, useLoaderData } from "@remix-run/react";
import { getParams } from "remix-params-helper";
import { z } from "zod";
import { supabaseClient } from "~/supabase";

interface Category {
  id: number;
  name: string;
}

interface Subcategory {
  id: number;
  name: string;
  categories: Category;
}

interface BrandOwner {
  id: number;
  name: string;
}

interface Brand {
  id: number;
  name: string;
  companies: BrandOwner;
}

interface SubBrand {
  id: number;
  name: string;
  brands: Brand;
}

interface Product {
  id: number;
  name: string;
  sub_brands: SubBrand;
  subcategory: Subcategory;
}

interface Profile {
  id: string;
  username: string;
}

interface CheckIn {
  id: number;
  rating: number | null;
  review: string | null;
  profiles: Profile;
}

type LoaderData = { products: Product[] };

const ParamsSchema = z.object({
  category: z.string(),
  subcategory: z.string(),
  brandOwner: z.string(),
});

export const action: ActionFunction = async ({ request, params }) => {};

export const loader: LoaderFunction = async ({ request, params }) => {
  const { success, data: decodedParams } = getParams(params, ParamsSchema);

  if (success) {
    const { data: products, error } = await supabaseClient
      .from("products")
      .select(
        "id, name, subcategories!inner(id, name, categories!inner(id, name)), sub_brands!inner(id, name, brands!inner(id, name, companies!inner(id, name)))"
      )
      .eq("sub_brands.brands.companies.name", decodedParams.brandOwner)
      .eq("subcategories.name", decodedParams.subcategory)
      .eq("subcategories.categories.name", decodedParams.category);

    if (products === null) {
      throw Error("No product found!");
    }

    return json<LoaderData>({ products });
  }

  return redirect("/");
};

export default function Screen() {
  const { products } = useLoaderData<LoaderData>();
  return (
    <>
      <h1>{products[0].sub_brands.brands.companies.name}</h1>
      {products.map((product) => (
        <div key={product.id}>
          {product.sub_brands.brands.name} {product.sub_brands.name}
          {product.name}
        </div>
      ))}
    </>
  );
}

export function CatchBoundary() {
  const caught = useCatch();

  return (
    <div>
      <h1>
        {caught.status} {caught.statusText}
      </h1>
    </div>
  );
}

export function ErrorBoundary({ error }: { error: Error }) {
  return (
    <div>
      <pre>{error.message}</pre>
    </div>
  );
}
