import Link from "next/link";
import { NextRouter, useRouter } from "next/router";
import * as qs from "querystring";
import React from "react";

import { Redirect } from "./Redirect";
import {
  AuthRestrict,
  SharedLayout,
  SharedLayoutChildProps,
  SharedLayoutProps,
} from "./SharedLayout";
import { StandardWidth } from "./StandardWidth";
import { styled } from "./stitches.config";
import { Warn } from "./Warn";

interface PageSpec {
  title: string;
  cy: string;
  warnIfUnverified?: boolean;
}

// TypeScript shenanigans (so we can still use `keyof typeof pages` later)
function page(spec: PageSpec): PageSpec {
  return spec;
}

const pages = {
  "/settings": page({
    title: "Account",
    cy: "settingslayout-link-profile",
  }),
  "/settings/security": page({
    title: "Security",
    cy: "settingslayout-link-password",
  }),
  "/settings/accounts": page({
    title: "Linked Accounts",
    cy: "settingslayout-link-accounts",
  }),
  "/settings/emails": page({
    title: "Emails",
    warnIfUnverified: true,
    cy: "settingslayout-link-emails",
  }),
  "/settings/delete": page({
    title: "Delete Account",
    cy: "settingslayout-link-delete",
  }),
};

export interface SettingsLayoutProps {
  query: SharedLayoutProps["query"];
  href: keyof typeof pages;
  children: React.ReactNode;
}

export function SettingsLayout({
  query,
  href: inHref,
  children,
}: SettingsLayoutProps) {
  const href = pages[inHref] ? inHref : Object.keys(pages)[0];
  const page = pages[href];
  // `useRouter()` sometimes returns null
  const router: NextRouter | null = useRouter();
  const fullHref =
    href + (router && router.query ? `?${qs.stringify(router.query)}` : "");
  return (
    <SharedLayout
      title={`Settings: ${page.title}`}
      noPad
      query={query}
      forbidWhen={AuthRestrict.LOGGED_OUT}
    >
      {({ currentUser, error, loading }: SharedLayoutChildProps) =>
        !currentUser && !error && !loading ? (
          <Redirect href={`/login?next=${encodeURIComponent(fullHref)}`} />
        ) : (
          <div>
            <Settings.Container>
              {Object.keys(pages).map((pageHref) => (
                <Settings.Tab key={pageHref}>
                  <Link href={pageHref}>
                    <a>
                      <Warn
                        okay={
                          !currentUser ||
                          currentUser.isVerified ||
                          !pages[pageHref].warnIfUnverified
                        }
                      >
                        <p>{pages[pageHref].title}</p>
                      </Warn>
                    </a>
                  </Link>
                </Settings.Tab>
              ))}
            </Settings.Container>
            <StandardWidth>{children}</StandardWidth>
          </div>
        )
      }
    </SharedLayout>
  );
}

const Settings = {
  Container: styled("div", { display: "flex" }),
  Tab: styled("div", { padding: "12px" }),
};
