import type { ActionFunction, LoaderFunction } from "@remix-run/node";
import { json, redirect } from "@remix-run/node";
import { Outlet, useFetcher, useLoaderData } from "@remix-run/react";
import { useEffect } from "react";
import { getParams } from "remix-params-helper";
import { z } from "zod";
import { Card } from "~/components/card";
import { styled } from "~/stitches.config";
import { supabaseClient } from "~/supabase";

type LoaderData = { user: any };

export const action: ActionFunction = async ({ request }) => {};

export const loader: LoaderFunction = async ({ request, params }) => {
  const { success, data: decodedParams } = getParams(
    params,
    z.object({
      id: z.string(),
    })
  );

  if (success) {
    console.log("decodedParams.id: ", decodedParams.id);

    const { data: user } = await supabaseClient
      .from("profiles")
      .select("*")
      .eq("id", decodedParams.id)
      .single();

    return json<LoaderData>({ user });
  }

  return redirect("/");
};

export default function Screen() {
  const { user } = useLoaderData<LoaderData>();
  console.log("user: ", user);
  const fetcher = useFetcher();

  useEffect(() => {
    const coo = fetcher.load(`./check-ins`);
    console.log("coo: ", coo);
  }, []);

  return (
    <Container>
      <Card.Container>
        <h1>{user?.username}</h1>
      </Card.Container>
      <Outlet />
    </Container>
  );
}

const Container = styled("div", {
  marginTop: "20px",
  display: "flex",
  flexDirection: "column",
  gap: "12px",
});
