import {
  Icon,
  Link,
  Navbar,
  NavbarBackLink,
  Page,
  Tabbar,
  TabbarLink,
} from "konsta/react";
import {
  Gear,
  PersonAltCircle,
  Search,
  ListDash,
  Person2Alt,
} from "framework7-icons/react";
import { useRouter } from "next/router";
import React, { ReactNode } from "react";
import Head from "next/head";

export const Layout: React.FC<{
  title: string;
  username: string;
  children?: ReactNode;
}> = ({ children, title, username }) => {
  const router = useRouter();
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
          <Link>
            <Person2Alt onClick={() => router.push(`/friends`)} />
          </Link>
        }
      />

      <main>{children}</main>
      <Tabbar labels={true} className="left-0 bottom-0 fixed">
        <TabbarLink
          onClick={() => router.push("/")}
          icon={<Icon ios={<ListDash className="w-7 h-7" />} />}
          label="Activity"
        />
        <TabbarLink
          onClick={() => router.push("/search")}
          icon={<Icon ios={<Search className="w-7 h-7" />} />}
          label="Search"
        />
        <TabbarLink
          onClick={() => router.push("/settings")}
          icon={<Icon ios={<Gear className="w-7 h-7" />} />}
          label="Settings"
        />
        <TabbarLink
          onClick={() => router.push(`/users/${username}`)}
          icon={<Icon ios={<PersonAltCircle className="w-7 h-7" />} />}
          label="Profile"
        />
      </Tabbar>
    </Page>
  );
};

export default Layout;
