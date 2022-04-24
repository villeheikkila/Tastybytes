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
import { authenticator } from "./auth.server";
import { Navigation } from "./components/navigation";
import { styled } from "./stitches.config";
import { supabaseClient } from "./supabase";
import type { Profile } from "./types/custom";
import { paths } from "./utils";
import { Configs } from "./utils/configs";

export const loader: LoaderFunction = async ({ request }) => {
  const session = await authenticator.isAuthenticated(request);

  const hideNavigation =
    request.url.includes("/login") || request.url.includes("/sign-up");

  if (session) {
    // TODO: Avoid loading this on every navigation
    const { data: user } = await supabaseClient
      .from("profiles")
      .select("*")
      .eq("id", session?.user?.id)
      .single();

    return json({
      user: user
        ? {
            ...user,
            avatar_url: paths.avatarUrl({
              profilePic: user.avatar_url,
              supabaseUrl: Configs.supabaseUrl,
            }),
          }
        : null,
      hideNavigation,
    });
  }

  return json({ user: null, hideNavigation });
};

export const action: ActionFunction = async ({ request }) => {
  await authenticator.logout(request, { redirectTo: "/login" });
};

export default function App() {
  const { user, hideNavigation } = useLoaderData<{
    user: Profile | null;
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
  user: Profile | null;
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
  marginTop: "80px",
  minHeight: "calc(100vh - 50px)",
  display: "flex",
  justifyContent: "center",
});
