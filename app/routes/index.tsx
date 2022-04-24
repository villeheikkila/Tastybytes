import type { LoaderFunction } from "@remix-run/node";
import { supabaseStrategy } from "~/auth.server";

export const loader: LoaderFunction = async ({ request }) => {
  await supabaseStrategy.checkSession(request, {
    failureRedirect: "/login",
  });

  return null;
};

export default function Index() {
  return (
    <>
      <h1>Activity Feed</h1>
    </>
  );
}
