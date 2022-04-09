import {
  ApolloClient,
  ApolloProvider,
  createHttpLink,
  InMemoryCache,
} from "@apollo/client";
import { setContext } from "@apollo/client/link/context";
import { createTheme, NextUIProvider } from "@nextui-org/react";
import { createClient } from "@supabase/supabase-js";
import React from "react";
import { createRoot } from "react-dom/client";
import { BrowserRouter } from "react-router-dom";
import { GetCheckInsQuery } from "./generated/graphql";
import { AuthProvider } from "./hooks/useAuth";
import { SupabaseProvider } from "./hooks/useSupabase";
import App from "./Routes";

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

const httpLink = createHttpLink({
  uri: `${supabaseUrl}/graphql/v1`,
});

const authLink = setContext((_, { headers }) => {
  return {
    headers: {
      ...headers,
      apikey: supabaseAnonKey,
    },
  };
});

const client = new ApolloClient({
  link: authLink.concat(httpLink),
  cache: new InMemoryCache({
    typePolicies: {
      Query: {
        fields: {
          profilesCollection: {
            keyArgs: ["type"],

            // While args.cursor may still be important for requesting
            // a given page, it no longer has any role to play in the
            // merge function.
            merge(existing, incoming, { readField }) {
              const merged = { ...existing };
              incoming.forEach((item) => {
                merged[readField("id", item)] = item;
              });
              return merged;
            },

            // Return all items stored so far, to avoid ambiguities
            // about the order of the items.
            read(existing) {
              return existing && Object.values(existing);
            },
          },
        },
      },
    },
  }),
});

const darkTheme = createTheme({
  type: "dark",
});

const supabaseClient = createClient(supabaseUrl, supabaseAnonKey);

const Providers: React.FC = ({ children }) => (
  <NextUIProvider theme={darkTheme}>
    <SupabaseProvider value={supabaseClient}>
      <ApolloProvider client={client}>
        <AuthProvider>
          <BrowserRouter>{children} </BrowserRouter>
        </AuthProvider>
      </ApolloProvider>
    </SupabaseProvider>
  </NextUIProvider>
);

const container = document.getElementById("root");
const root = createRoot(container!);

root.render(
  <React.StrictMode>
    <Providers>
      <App />
    </Providers>
  </React.StrictMode>
);
