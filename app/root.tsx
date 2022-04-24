import type { ActionFunction, LoaderFunction } from "@remix-run/node";
import { json } from "@remix-run/node";
import {
  Links,
  LiveReload,
  Meta,
  Outlet,
  Scripts,
  ScrollRestoration,
  useLoaderData,
} from "@remix-run/react";
import type { User } from "@supabase/supabase-js";
import { authenticator, supabaseStrategy } from "./auth.server";
import { Navigation } from "./components/navigation";
import { styled } from "./stitches.config";
import { supabaseClient } from "./supabase";

export const loader: LoaderFunction = async ({ request }) => {
  const session = await supabaseStrategy.checkSession(request);

  const hideNavigation =
    request.url.includes("/login") || request.url.includes("/sign-up");

  if (session?.user?.id) {
    console.log("session?.user: ", session?.user);
    const { data: user } = await supabaseClient
      .from("profiles")
      .select("username")
      .eq("id", session.user.id)
      .single();

    console.log("user: ", user);
  }

  return json({ user: session?.user ?? null, hideNavigation });
};

export const action: ActionFunction = async ({ request }) => {
  await authenticator.logout(request, { redirectTo: "/login" });
};

export default function App() {
  const { user, hideNavigation } = useLoaderData<{
    user: User | null;
    hideNavigation: boolean;
  }>();

  return (
    <Document title="tasted" user={user} hideNavigation={hideNavigation}>
      <Outlet />
    </Document>
  );
}

function Document({
  hideNavigation,
  children,
  title,
  user,
}: {
  children: React.ReactNode;
  title?: string;
  user: User | null;
  hideNavigation: boolean;
}) {
  return (
    <html lang="en">
      <head>
        <meta charSet="utf-8" />
        <meta name="viewport" content="width=device-width,initial-scale=1" />
        <Meta />
        <Links />
        {title ? <title>{title}</title> : null}
      </head>
      <body>
        {!hideNavigation && <Navigation user={user} />}
        <Content>{children}</Content>
        <Scripts />
        <ScrollRestoration />
        {process.env.NODE_ENV === "development" && <LiveReload />}
      </body>
    </html>
  );
}

const Content = styled("div", {
  marginTop: "70px",
  minHeight: "calc(100vh - 50px)",
  display: "flex",
  justifyContent: "center",
});
