import { ApolloError, QueryResult, useApolloClient } from "@apollo/client";
import { author, projectName } from "@app/config";
import {
  SharedLayout_QueryFragment,
  SharedLayout_UserFragment,
  useCurrentUserUpdatedSubscription,
  useLogoutMutation,
} from "@app/graphql";
import Head from "next/head";
import Link from "next/link";
import Router, { useRouter } from "next/router";
import * as React from "react";
import { useCallback } from "react";

import { ErrorAlert, StandardWidth, Warn } from ".";
import { Avatar } from "./Avatar";
import { Redirect } from "./Redirect";

export const contentMinHeight = "calc(100vh - 64px - 70px)";

export interface SharedLayoutChildProps {
  error?: ApolloError | Error;
  loading: boolean;
  currentUser?: SharedLayout_UserFragment | null;
}

export enum AuthRestrict {
  NEVER = 0,
  LOGGED_OUT = 1 << 0,
  LOGGED_IN = 1 << 1,
  NOT_ADMIN = 1 << 2,
}

export interface SharedLayoutProps {
  /*
   * We're expecting lots of different queries to be passed through here, and
   * for them to have this common required data we need. Methods like
   * `subscribeToMore` are too specific (and we don't need them) so we're going
   * to drop them from the data requirements.
   *
   * NOTE: we're not fetching this query internally because we want the entire
   * page to be fetchable via a single GraphQL query, rather than multiple
   * chained queries.
   */
  query: Pick<
    QueryResult<SharedLayout_QueryFragment>,
    "data" | "loading" | "error" | "networkStatus" | "client" | "refetch"
  >;

  title: string;
  titleHref?: string;
  titleHrefAs?: string;
  children:
    | React.ReactNode
    | ((props: SharedLayoutChildProps) => React.ReactNode);
  noPad?: boolean;
  noHandleErrors?: boolean;
  forbidWhen?: AuthRestrict;
}

/* The Apollo `useSubscription` hook doesn't currently allow skipping the
 * subscription; we only want it when the user is logged in, so we conditionally
 * call this stub component.
 */
function CurrentUserUpdatedSubscription() {
  /*
   * This will set up a GraphQL subscription monitoring for changes to the
   * current user. Interestingly we don't need to actually _do_ anything - no
   * rendering or similar - because the payload of this mutation will
   * automatically update Apollo's cache which will cause the data to be
   * re-rendered wherever appropriate.
   */
  useCurrentUserUpdatedSubscription();
  return null;
}

export function SharedLayout({
  title,
  titleHref,
  titleHrefAs,
  noPad = false,
  noHandleErrors = false,
  query,
  forbidWhen = AuthRestrict.NEVER,
  children,
}: SharedLayoutProps) {
  const router = useRouter();
  const currentUrl = router.asPath;
  const client = useApolloClient();
  const [logout] = useLogoutMutation();
  const handleLogout = useCallback(() => {
    console.log("Hei");
    const reset = async () => {
      Router.events.off("routeChangeComplete", reset);
      try {
        await logout();
        client.resetStore();
      } catch (e) {
        console.error(e);
        // Something went wrong; redirect to /logout to force logout.
        window.location.href = "/logout";
      }
    };
    Router.events.on("routeChangeComplete", reset);
    Router.push("/");
  }, [client, logout]);
  const forbidsLoggedIn = forbidWhen & AuthRestrict.LOGGED_IN;
  const forbidsLoggedOut = forbidWhen & AuthRestrict.LOGGED_OUT;
  const forbidsNotAdmin = forbidWhen & AuthRestrict.NOT_ADMIN;
  const renderChildren = (props: SharedLayoutChildProps) => {
    const inner =
      props.error && !props.loading && !noHandleErrors ? (
        <>
          {process.env.NODE_ENV === "development" ? (
            <ErrorAlert error={props.error} />
          ) : null}
        </>
      ) : typeof children === "function" ? (
        children(props)
      ) : (
        children
      );
    if (
      data &&
      data.currentUser &&
      (forbidsLoggedIn || (forbidsNotAdmin && !data.currentUser.isAdmin))
    ) {
      return (
        <StandardWidth>
          <Redirect href={"/"} />
        </StandardWidth>
      );
    } else if (
      data &&
      data.currentUser === null &&
      !loading &&
      !error &&
      forbidsLoggedOut
    ) {
      return (
        <Redirect href={`/login?next=${encodeURIComponent(router.asPath)}`} />
      );
    }

    return noPad ? inner : <StandardWidth>{inner}</StandardWidth>;
  };
  const { data, loading, error } = query;

  return (
    <div>
      {data && data.currentUser ? <CurrentUserUpdatedSubscription /> : null}
      <header
        style={{
          boxShadow: "0 2px 8px #f0f1f2",
          zIndex: 1,
          overflow: "hidden",
        }}
      >
        <button onClick={handleLogout}>Logout</button>

        <Head>
          <title>{title ? `${title} — ${projectName}` : projectName}</title>
        </Head>
        <div>
          <div>
            <Link href="/">
              <a>{projectName}</a>
            </Link>
          </div>
          <div>
            <h3>
              {titleHref ? (
                <Link href={titleHref} as={titleHrefAs}>
                  <a>{title}</a>
                </Link>
              ) : (
                title
              )}
            </h3>
          </div>
          <div style={{ textAlign: "right" }}>
            {data && data.currentUser ? (
              <div>
                <div>
                  {data.currentUser.organizationMemberships.nodes.map(
                    ({ organization, isOwner }) => (
                      <div key={organization?.id}>
                        <Link
                          href={`/o/[slug]`}
                          as={`/o/${organization?.slug}`}
                        >
                          <a>
                            {organization?.name}
                            {isOwner ? <span> </span> : ""}
                          </a>
                        </Link>
                      </div>
                    )
                  )}
                  <div>
                    <Link href="/create-organization">
                      <a>Create organization</a>
                    </Link>
                  </div>
                  <div>
                    <Link href="/settings">
                      <a>
                        <Warn okay={data.currentUser.isVerified}>Settings</Warn>
                      </a>
                    </Link>
                  </div>
                  <div>
                    <button onClick={handleLogout}>Logout</button>
                  </div>
                </div>
                <span style={{ whiteSpace: "nowrap" }}>
                  <Avatar
                    name={data.currentUser.name || "?"}
                    imageUrl={data.currentUser.avatarUrl}
                    status={!data.currentUser.isVerified ? "warn" : undefined}
                  />
                </span>
              </div>
            ) : forbidsLoggedIn ? null : (
              <Link href={`/login?next=${encodeURIComponent(currentUrl)}`}>
                <a>Sign in</a>
              </Link>
            )}
          </div>
        </div>
      </header>
      <div style={{ minHeight: contentMinHeight }}>
        {renderChildren({
          error,
          loading,
          currentUser: data && data.currentUser,
        })}
      </div>
      <footer>
        <div
          style={{
            display: "flex",
            flexWrap: "wrap",
            justifyContent: "space-between",
          }}
        >
          <p>
            Copyright &copy; {new Date().getFullYear()} {author}. All rights
            reserved.
            {process.env.T_AND_C_URL ? (
              <span>
                {" "}
                <a
                  style={{ textDecoration: "underline" }}
                  href={process.env.T_AND_C_URL}
                >
                  Terms and conditions
                </a>
              </span>
            ) : null}
          </p>
        </div>
      </footer>
    </div>
  );
}
