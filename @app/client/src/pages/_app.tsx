import { ApolloClient, ApolloProvider } from "@apollo/client";
import { globalStyles } from "@app/components";
import { withApollo } from "@app/common";
import { IdProvider } from "@radix-ui/react-id";
import App from "next/app";
import Router from "next/router";
import * as React from "react";

declare global {
  interface Window {
    __GRAPHILE_APP__: {
      ROOT_URL?: string;
      T_AND_C_URL?: string;
    };
  }
}

if (typeof window !== "undefined") {
  const nextDataEl = document.getElementById("__NEXT_DATA__");
  if (!nextDataEl || !nextDataEl.textContent) {
    throw new Error("Cannot read from __NEXT_DATA__ element");
  }
  const data = JSON.parse(nextDataEl.textContent);
  window.__GRAPHILE_APP__ = {
    ROOT_URL: data.query.ROOT_URL,
    T_AND_C_URL: data.query.T_AND_C_URL,
  };

  Router.events.on("routeChangeStart", () => {
    <div>Done</div>;
  });

  Router.events.on("routeChangeComplete", () => {
    <div>Done</div>;
  });
  Router.events.on("routeChangeError", (err: Error | string) => {
    <div>Done</div>;
    if (err["cancelled"]) {
      // No worries; you deliberately cancelled it
    } else {
      console.dir({
        message: "Page load failed",
        description: `This is very embarrassing! Please reload the page. Further error details: ${
          typeof err === "string" ? err : err.message
        }`,
        duration: 0,
      });
    }
  });
}

interface MyAppProps extends App {
  Component: any;
  pageProps: any;
  apollo: ApolloClient<any>;
}

const MyApp = ({ Component, pageProps, apollo }: MyAppProps) => {
  globalStyles();

  return (
    <ApolloProvider client={apollo}>
      <IdProvider>
        <Component {...pageProps} />
      </IdProvider>
    </ApolloProvider>
  );
};

MyApp.getInitialProps = async ({ Component, ctx }: any) => {
  let pageProps = {};

  if (Component.getInitialProps) {
    pageProps = await Component.getInitialProps(ctx);
  }

  return { pageProps };
};

export default withApollo(MyApp);
