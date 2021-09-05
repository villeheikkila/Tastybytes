import { useApolloClient } from "@apollo/client";
import Router from "next/router";
import React, { useEffect } from "react";

import { SharedLayout } from "./SharedLayout";
import { StandardWidth } from "./StandardWidth";

export interface RedirectProps {
  href: string;
  as?: string;
  layout?: boolean;
}

export const Redirect: React.FC<RedirectProps> = ({ href, as, layout }) => {
  const client = useApolloClient();

  useEffect(() => {
    Router.push(href, as);
  }, [as, href]);

  if (layout) {
    return (
      <SharedLayout
        title="Redirecting..."
        query={{
          loading: true,
          data: undefined,
          error: undefined,
          networkStatus: 0,
          client,
          refetch: (async () => {
            throw new Error("Redirecting...");
          }) as any,
        }}
      >
        <div />
      </SharedLayout>
    );
  } else {
    return (
      <StandardWidth>
        <h3>Redirecting...</h3>
        <div />
      </StandardWidth>
    );
  }
};
