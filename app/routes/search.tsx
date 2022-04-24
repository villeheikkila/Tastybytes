import type { LoaderFunction } from "@remix-run/node";
import { json } from "@remix-run/node";
import { Link, useLoaderData } from "@remix-run/react";
import { getSearchParams } from "remix-params-helper";
import { z } from "zod";
import { Card } from "~/components/card";
import { styled } from "~/stitches.config";
import { supabaseClient } from "~/supabase";
import { paths } from "~/utils";

export const loader: LoaderFunction = async ({ request, params }) => {
  const { success, data: decodedParams } = getSearchParams(
    request,
    z.object({
      term: z.string(),
    })
  );

  if (success) {
    const { data: searchResultIds } = await supabaseClient
      .from("materialized_search_products")
      .select("id")
      .textSearch("product_t", decodedParams.term);

    if (searchResultIds) {
      const { data: searchResults } = await supabaseClient
        .from("products")
        .select(
          "id, name, subcategories!inner(id, name, categories!inner(id, name)), sub_brands!inner(id, name, brands!inner(id, name, companies!inner(id, name)))"
        )
        .in(
          "id",
          searchResultIds.map(({ id }) => id)
        );

      return json({ searchResults });
    }
  }

  return json({ searchResults: [] });
};

export default function Index() {
  const { searchResults } = useLoaderData();

  return (
    <>
      <Container>
        <h1>Search results</h1>
        {searchResults.map((result: any) => (
          <Link to={paths.product(result)} key={result.id}>
            <Card.Container>
              <h1>
                {result.sub_brands.brands.companies.name}
                {result.sub_brands.brands.name} {result.sub_brands.name}
                {result.name}
              </h1>
            </Card.Container>
          </Link>
        ))}
      </Container>
    </>
  );
}

const Container = styled("div", {
  marginTop: "20px",
  display: "flex",
  flexDirection: "column",
  gap: "12px",
});
