import type { ActionFunction, LoaderFunction } from "remix";
import { json, redirect } from "@remix-run/node";
import { useLoaderData } from "@remix-run/react";
import { supabaseClient } from "~/supabase";
import { Stars } from "~/components/stars";
import { getParams } from "remix-params-helper";
import { z } from "zod";
import { styled } from "~/stitches.config";

export function headers() {
  return {
    "Cache-Control": "max-age=3600, s-maxage=4200",
  };
}

type LoaderData = { checkIns: any[]; user: any };

export const action: ActionFunction = async ({ request }) => {};

const ParamsSchema = z.object({
  username: z.string(),
});

export const loader: LoaderFunction = async ({ request, params }) => {
  const { success, data: decodedParams } = getParams(params, ParamsSchema);

  if (success) {
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
      .limit(10);
    console.log("error: ", error);

    return json<LoaderData>({ checkIns: checkIns ?? [], user });
  }

  return redirect("/");
};

export default function Screen() {
  const { checkIns, user } = useLoaderData<LoaderData>();

  return (
    <Container>
      <h1>{user.username}</h1>
      {checkIns.map((checkIn) => (
        <Wrapper key={checkIn.id}>
          {user.username} is tasting {checkIn.products.sub_brands.brands.name}{" "}
          {checkIn.products.sub_brands.name} {checkIn.products.name} from{" "}
          {checkIn.products.sub_brands.brands.companies.name}
          <Stars rating={checkIn.rating} />
        </Wrapper>
      ))}
    </Container>
  );
}

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

export const Card = {
  Container,
  Wrapper,
};
