import { UserContextProvider } from "../lib/UserContext";
import { supabase } from "../utils/initSupabase";
import { createTheme, NextUIProvider } from "@nextui-org/react";
import { AppProps } from "next/app";

const darkTheme = createTheme({
  type: "dark",
  theme: {
    colors: {
      background: "rgb(24, 24, 24)",
    },
    fonts: {
      sans: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol"',
    },
  },
});

export default function MyApp({ Component, pageProps }: AppProps) {
  return (
    <main>
      <UserContextProvider supabaseClient={supabase}>
        <NextUIProvider theme={darkTheme}>
          <Component {...pageProps} />
        </NextUIProvider>
      </UserContextProvider>
    </main>
  );
}
