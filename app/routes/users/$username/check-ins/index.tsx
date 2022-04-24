import type { ActionFunction, LoaderFunction } from "@remix-run/node";
import { json, redirect } from "@remix-run/node";
import { Link, useFetcher, useFetchers, useLoaderData } from "@remix-run/react";
import { supabaseClient } from "~/supabase";
import { Stars } from "~/components/stars";
import { getParams } from "remix-params-helper";
import { z } from "zod";
import { styled } from "~/stitches.config";
import { useInView } from "react-intersection-observer";
import { useEffect, useState } from "react";
import { getSearchParams } from "remix-params-helper";

type LoaderData = { checkIns: any[]; user: any };

export const action: ActionFunction = async ({ request }) => {};

const ParamsSchema = z.object({
  username: z.string(),
});

export const getPagination = (page: number, size: number) => {
  const limit = size ? +size : 3;
  const from = page ? page * limit : 0;
  const to = page ? from + size : size;

  return { from, to };
};

export const loader: LoaderFunction = async ({ request, params }) => {
  const searchParams = getSearchParams(
    request,
    z.object({
      page: z.number().optional(),
    })
  );

  const { success, data: decodedParams } = getParams(params, ParamsSchema);
  console.log("decodedParams: ", decodedParams);

  if (success) {
    const { from, to } = getPagination(searchParams.data?.page ?? 0, 10);

    const { data: user } = await supabaseClient
      .from("profiles")
      .select("username")
      .eq("username", decodedParams.username)
      .single();

    const { data: checkIns, error } = await supabaseClient
      .from("check_ins")
      .select(
        "rating, review, product_id, profiles (id, username), products (id, name, sub_brands (id, name, brands (id, name, companies (id, name))), subcategories (id, name, categories (id, name)))"
      )
      .eq("profiles.username", decodedParams.username)
      .limit(10)
      .range(from, to);

    console.log("error: ", error);

    return json<LoaderData>({ checkIns: checkIns ?? [], user });
  }

  return redirect("/");
};

export default function Screen() {
  const { checkIns: initialCheckIns, user } = useLoaderData<LoaderData>();
  const [page, setPage] = useState(2);
  const fetcher = useFetcher();
  console.log("fetcher: ", fetcher.state);
  console.log("fetcher: ", fetcher.data);
  const { ref, inView, entry } = useInView();
  const [checkIns, setCheckIns] = useState(initialCheckIns);
  const [shouldFetch, setShouldFetch] = useState(true);
  const fetchers = useFetchers();
  console.log("fetchers: ", fetchers);

  useEffect(() => {
    if (inView && shouldFetch) {
      console.log("inView: ", inView);
      const coo = fetcher.load(`./?page=${page}`);
      console.log("coo: ", coo);
      setShouldFetch(false);
    }
  }, [inView, fetcher, page, shouldFetch]);

  useEffect(() => {
    if (fetcher.data && fetcher.data.length === 0) {
      setShouldFetch(false);
      return;
    }

    if (fetcher.data && fetcher.data.length > 0) {
      setCheckIns((prevPhotos: any[]) => [...prevPhotos, ...fetcher.data]);
      setPage((page: number) => page + 1);
      setShouldFetch(false);
    }
  }, [fetcher.data]);

  return (
    <Container>
      {checkIns.map((checkIn) => (
        <Wrapper key={checkIn.id}>
          <div>
            {user.username} is tasting{" "}
            <Link to={createProductLink(checkIn.products)}>
              {checkIn.products.sub_brands.brands.name}{" "}
              {checkIn.products.sub_brands.name} {checkIn.products.name}{" "}
            </Link>
            from {checkIn.products.sub_brands.brands.companies.name}
          </div>
          <Stars rating={checkIn.rating} />
        </Wrapper>
      ))}
      <div ref={ref} />
    </Container>
  );
}

const createProductLink = (product: any) => {
  return `/products/${product.subcategories.categories.name}/${product.subcategories.name}/${product.sub_brands.brands.companies.name}/${product.sub_brands.brands.name}/${product.sub_brands.name}/${product.name}`;
};

const Wrapper = styled("div", {
  display: "flex",
  flexDirection: "column",
  gap: "4px",
  borderRadius: 6,
  padding: 24,
  width: "min(95vw, 36rem)",
  backdropFilter: "blur(20px)",
  backgroundColor: "rgba(0, 0, 0, 0.8)",
  boxShadow:
    "hsl(206 22% 7% / 35%) 0px 10px 38px -10px, hsl(206 22% 7% / 20%) 0px 10px 20px -15px",
  "@media (prefers-reduced-motion: no-preference)": {
    animationDuration: "400ms",
    animationTimingFunction: "cubic-bezier(0.16, 1, 0.3, 1)",
  },
});

const Container = styled("div", {
  marginTop: "20px",
  display: "flex",
  flexDirection: "column",
  gap: "12px",
});
