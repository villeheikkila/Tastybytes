import { supabaseClient } from "@supabase/auth-helpers-nextjs";
import { UserProvider } from "@supabase/auth-helpers-react";
import type { AppProps } from "next/app";
import "../styles/globals.css";
import { App } from "konsta/react";

export default function MyApp({ Component, pageProps }: AppProps) {
  return (
    <UserProvider supabaseClient={supabaseClient}>
      <App theme="ios">
        <Component {...pageProps} />
      </App>
    </UserProvider>
  );
}
