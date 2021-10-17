import { ApolloError, QueryResult, useApolloClient } from "@apollo/client";
import {
  SharedLayout_QueryFragment,
  SharedLayout_UserFragment,
  useCurrentUserUpdatedSubscription,
  useLogoutMutation,
} from "@app/graphql";
import { blackA, violet } from "@radix-ui/colors";
import Head from "next/head";
import Image from "next/image";
import Link from "next/link";
import Router, { useRouter } from "next/router";
import * as React from "react";
import { useCallback } from "react";

import { ErrorAlert, StandardWidth, Warn } from ".";
import { Avatar } from "./Avatar";
import { Dropdown } from "./Dropdown";
import { Redirect } from "./Redirect";
import { styled } from "./stitches.config";

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
  hideNavigation?: boolean;
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
  noPad = false,
  noHandleErrors = false,
  query,
  forbidWhen = AuthRestrict.NEVER,
  hideNavigation,
  children,
}: SharedLayoutProps) {
  const router = useRouter();
  const currentUrl = router.asPath;

  const client = useApolloClient();
  const [logout] = useLogoutMutation();

  const handleLogout = useCallback(() => {
    const reset = async () => {
      Router.events.off("routeChangeComplete", reset);
      try {
        await logout();
        client.resetStore();
      } catch (e) {
        console.error(e);
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
    <>
      {data && data.currentUser ? <CurrentUserUpdatedSubscription /> : null}
      <Head>
        <title>{title ? `${title} — maku` : "maku"}</title>
      </Head>
      <Navigation.Header
        css={{ visibility: hideNavigation ? "hidden" : "visible" }}
      >
        <Navigation.Content>
          <Link href="/">
            <ProjectLogo>
              <Image color="white" src="/maku.svg" height={32} width={32} />

              <LogoText>Maku</LogoText>
            </ProjectLogo>
          </Link>

          <div>
            {data && data.currentUser ? (
              <Dropdown.Menu>
                <Dropdown.Trigger asChild>
                  <IconButton>
                    <Avatar
                      name={data.currentUser.username || "?"}
                      imageUrl={data.currentUser.avatarUrl}
                      status={!data.currentUser.isVerified ? "warn" : undefined}
                    />
                  </IconButton>
                </Dropdown.Trigger>

                <Dropdown.Content sideOffset={1}>
                  <Dropdown.Item>
                    <Link
                      href={{
                        pathname: "/u/[user]",
                        query: { user: "villeheikkila" },
                      }}
                    >
                      Profile
                    </Link>
                  </Dropdown.Item>
                  <Dropdown.Item>
                    <a href="/settings">
                      <Warn okay={data.currentUser.isVerified}>Settings</Warn>
                    </a>
                  </Dropdown.Item>
                  <Dropdown.Item>
                    <button onClick={handleLogout}>Logout</button>
                  </Dropdown.Item>
                </Dropdown.Content>
              </Dropdown.Menu>
            ) : forbidsLoggedIn ? null : (
              <LogInLink href={`/login?next=${encodeURIComponent(currentUrl)}`}>
                Sign in
              </LogInLink>
            )}
          </div>
        </Navigation.Content>
      </Navigation.Header>
      <Content>
        {renderChildren({
          error,
          loading,
          currentUser: data && data.currentUser,
        })}
      </Content>
      <Footer.Wrapper>
        <Footer.Content>
          <p>
            Copyright &copy; {new Date().getFullYear()} Ville Heikkilä. All
            rights reserved.
          </p>
        </Footer.Content>
      </Footer.Wrapper>
    </>
  );
}

const Navigation = {
  Header: styled("header", {
    position: "fixed",
    zIndex: 10,
    top: 0,
    left: 0,

    height: "70px",
    width: "100%",

    display: "flex",
    justifyContent: "center",
    alignContent: "center",

    borderBottom: "1px solid #5f6368",
  }),
  Content: styled("div", {
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
    width: "700px",
    backgroundColor: "$midnight",
    padding: "12px",
  }),
};

const Content = styled("div", {
  marginTop: "70px",
  minHeight: "calc(100vh - 50px)",
  display: "flex",
  justifyContent: "center",
});

const ProjectLogo = styled("div", {
  display: "flex",
  alignItems: "center",
  gap: "8px",

  ":hover": {
    color: "$blue",
  },
});

const LogoText = styled("h1", {
  textTransform: "capitalize",
  fontSize: "36px",
  color: "white",
  fontWeight: "bold",
  alignText: "center",
});

const LogInLink = styled(Link, {});

const IconButton = styled("button", {
  all: "unset",
  fontFamily: "inherit",
  borderRadius: "100%",
  height: "42px",
  width: "42px",
  display: "inline-flex",
  alignItems: "center",
  justifyContent: "center",
  color: violet.violet11,
  backgroundColor: "white",
  boxShadow: `0 2px 10px ${blackA.blackA7}`,
  "&:hover": { backgroundColor: violet.violet3 },
  "&:focus": { boxShadow: `0 0 0 2px black` },
});

const Footer = {
  Wrapper: styled("div", {
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    justifyContent: "center",
    height: "50px",
  }),
  Content: styled("span", {}),
};
