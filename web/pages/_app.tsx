import { supabaseClient } from "@supabase/auth-helpers-nextjs";
import { UserProvider } from "@supabase/auth-helpers-react";
import { App } from "konsta/react";
import type { AppProps } from "next/app";
import Head from "next/head";
import "../styles/globals.css";
import { ProfileProvider } from "../utils/hooks";

export default function MyApp({ Component, pageProps }: AppProps) {
  return (
    <UserProvider supabaseClient={supabaseClient}>
      <ProfileProvider>
        <Head>
          <meta
            name="viewport"
            content="minimum-scale=1, initial-scale=1, width=device-width, shrink-to-fit=no, user-scalable=no, viewport-fit=cover"
          />
        </Head>
        <App theme="ios" safeAreas>
          <Component {...pageProps} />
        </App>
      </ProfileProvider>
    </UserProvider>
  );
}
