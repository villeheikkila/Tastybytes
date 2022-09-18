import {
  Gear,
  ListDash,
  Person2Alt,
  PersonAltCircle,
  Search,
} from "framework7-icons/react";
import {
  Icon,
  Link,
  Navbar,
  NavbarBackLink,
  Page,
  Tabbar,
  TabbarLink,
} from "konsta/react";
import Head from "next/head";
import { useRouter } from "next/router";
import React, { ReactNode } from "react";
import { useProfile } from "../utils/hooks";
import { paths } from "../utils/paths";

export const Layout: React.FC<{
  title: string;
  children?: ReactNode;
}> = ({ children, title }) => {
  const router = useRouter();
  const profile = useProfile();
  const pageTitle = `Tasted - ${title}`;

  return (
    <Page>
      <Head>
        <title>{pageTitle}</title>
      </Head>
      <Navbar
        title={title}
        left={<NavbarBackLink onClick={() => router.back()} />}
        right={
          profile && (
            <Link>
              <Person2Alt
                onClick={() =>
                  router.push(paths.user.friends(profile.username))
                }
              />
            </Link>
          )
        }
      />

      <main>{children}</main>
      <Tabbar labels={true} className="left-0 bottom-0 fixed">
        {profile && (
          <TabbarLink
            onClick={() => router.push(paths.activity)}
            icon={<Icon ios={<ListDash className="w-7 h-7" />} />}
            label="Activity"
          />
        )}
        <TabbarLink
          onClick={() => router.push(paths.search)}
          icon={<Icon ios={<Search className="w-7 h-7" />} />}
          label="Search"
        />
        {profile && (
          <TabbarLink
            onClick={() => router.push(paths.settings)}
            icon={<Icon ios={<Gear className="w-7 h-7" />} />}
            label="Settings"
          />
        )}
        {profile && (
          <TabbarLink
            onClick={() => router.push(paths.user.root(profile.username))}
            icon={<Icon ios={<PersonAltCircle className="w-7 h-7" />} />}
            label="Profile"
          />
        )}
      </Tabbar>
    </Page>
  );
};

export default Layout;
