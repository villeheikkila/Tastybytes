import { OrganizationPage_OrganizationFragment } from "@app/graphql";
import Link from "next/link";
import React, { useMemo } from "react";

import { StandardWidth } from "./StandardWidth";

interface PageSpec {
  title: string;
  cy: string;
}

// TypeScript shenanigans (so we can still use `keyof typeof pages` later)
function page(spec: PageSpec): PageSpec {
  return spec;
}

const makePages = (_org: OrganizationPage_OrganizationFragment) => ({
  [`/o/[slug]/settings`]: page({
    title: "Profile",
    cy: "orgsettingslayout-link-profile",
  }),
  [`/o/[slug]/settings/members`]: page({
    title: "Members",
    cy: "orgsettingslayout-link-members",
  }),
  [`/o/[slug]/settings/delete`]: page({
    title: "Delete Organization",
    cy: "orgsettingslayout-link-delete",
  }),
});

export interface OrganizationSettingsLayoutProps {
  href: string;
  organization: OrganizationPage_OrganizationFragment;
  children: React.ReactNode;
}

export function OrganizationSettingsLayout({
  href: inHref,
  organization,
  children,
}: OrganizationSettingsLayoutProps) {
  const pages = useMemo(() => makePages(organization), [organization]);
  const href = pages[inHref] ? inHref : Object.keys(pages)[0];
  /*
  const page = pages[href];
  // `useRouter()` sometimes returns null
  const router: NextRouter | null = useRouter();
  const fullHref =
    href + (router && router.query ? `?${qs.stringify(router.query)}` : "");
    */
  return (
    <div style={{ minHeight: "1000px" }}>
      <div>
        <div key={href}>
          {Object.keys(pages).map((pageHref) => (
            <div key={pageHref}>
              <Link
                href={pageHref}
                as={pageHref.replace("[slug]", organization.slug)}
              >
                <a>
                  <p {...pages[pageHref].titleProps}>{pages[pageHref].title}</p>
                </a>
              </Link>
            </div>
          ))}
        </div>
      </div>
      <div>
        <StandardWidth>{children}</StandardWidth>
      </div>
    </div>
  );
}
