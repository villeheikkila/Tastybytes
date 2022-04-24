import type { ActionFunction, LoaderFunction } from "@remix-run/node";
import { json } from "@remix-run/node";
import { useLoaderData } from "@remix-run/react";
import { supabaseClient } from "~/supabase";
import { Stars } from "~/components/stars";

export function headers() {
  return {
    "Cache-Control": "max-age=3600, s-maxage=4200",
  };
}

type LoaderData = { email?: string; data: MaterializedCheckIn[] | null };

export const action: ActionFunction = async ({ request }) => {};

interface MaterializedCheckIn {
  category: string;
  subcategory: string;
  manufacturer: string;
  brand_owner: string;
  brand: string;
  "sub-brand": string | null;
  name: string | null;
  description: string | null;
  rating: number;
}
export const loader: LoaderFunction = async ({ request }) => {
  const { data, error } = await supabaseClient
    .from("materialized_overview")
    .select(`*`)
    .limit(2500);
  return json<LoaderData>({ data });
};

export default function Screen() {
  const { email, data } = useLoaderData<LoaderData>();
  return (
    <>
      <h1>Hello {email}</h1>
      {data && (
        <div>
          <table>
            <thead>
              <tr>
                <th>Category</th>
                <th>Subcategory</th>
                <th>Manufacturer</th>
                <th>Brand Owner</th>
                <th>Brand</th>
                <th>Sub-brand</th>
                <th>Flavour</th>
                <th>Description</th>
                <th>Rating</th>
              </tr>
            </thead>
            <tbody>
              {data.map((row, i) => (
                <tr key={i}>
                  <td>{row.category}</td>
                  <td>{row.subcategory}</td>
                  <td>{row.manufacturer}</td>
                  <td>{row.brand_owner}</td>
                  <td>{row.brand}</td>
                  <td>{row["sub-brand"]}</td>
                  <td>{row.name}</td>
                  <td>{row.description}</td>
                  <td>
                    <Stars rating={row.rating * 2} />
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </>
  );
}
