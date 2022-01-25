import {
  Form,
  Link,
  Links,
  LiveReload,
  LoaderFunction,
  Meta,
  MetaFunction,
  Outlet,
  Scripts,
  ScrollRestoration,
  useCatch,
  useLoaderData,
} from "remix";
import SDK from "./api.server";
import { Avatar } from "./components/avatar";
import { Dropdown } from "./components/dropdown";
import Input from "./components/input";
import { globals, styled } from "./stitches.config";
import { paths } from "./utils/paths";
import { getUser } from "./utils/session.server";

export const meta: MetaFunction = () => {
  return { title: "Tasted" };
};

export const loader: LoaderFunction = async ({ request }) => {
  const user = await getUser(request);
  return user;
};

export default function App() {
  return (
    <Document title="Tasted">
      <NavigationBar />
      <Content>
        <Outlet />
      </Content>
      <FooterBar />
    </Document>
  );
}

const FooterBar = () => (
  <Footer.Wrapper>
    <Footer.Content>
      <p>
        Copyright &copy; {new Date().getFullYear()} Ville Heikkilä. All rights
        reserved.
      </p>
    </Footer.Content>
  </Footer.Wrapper>
);

const NavigationBar = () => {
  const data = useLoaderData<SDK.GetUserByIdQuery>();

  return (
    <Navigation.Header>
      <Navigation.Content>
        <Link to="/">
          <ProjectLogo>
            <img color="white" src="/maku.svg" height={32} width={32} />
            <LogoText>Tasted</LogoText>
          </ProjectLogo>
        </Link>
        <Search />
        {data?.user ? (
          <DropdownMenu user={data.user} />
        ) : (
          <Link to="/login">Login</Link>
        )}
      </Navigation.Content>
    </Navigation.Header>
  );
};

export const Search = () => {
  return (
    <form method="get" action="/search">
      <Input id="search" name="term" type="text" placeholder="Search..." />
      <button type="submit">Search</button>
    </form>
  );
};

const DropdownMenu: React.FC<{ user: SDK.Basic_UserFragment }> = ({ user }) => {
  return (
    <Dropdown.Menu>
      <Dropdown.Trigger asChild>
        <IconButton>
          <Avatar name={user.username} status={undefined} />
        </IconButton>
      </Dropdown.Trigger>

      <Dropdown.Content sideOffset={-53}>
        <Dropdown.Item>
          <Link to={paths.user(user.username)}>Profile</Link>
        </Dropdown.Item>
        <Dropdown.Separator />
        <Dropdown.Item>
          <Link to={paths.settings}>Settings</Link>
        </Dropdown.Item>
        <Dropdown.Separator />
        <Dropdown.Item alignment="centered">
          <Form action={paths.logout} method="post">
            <SquareButton type="submit">Logout</SquareButton>
          </Form>
        </Dropdown.Item>
      </Dropdown.Content>
    </Dropdown.Menu>
  );
};

const SquareButton = styled("button", {
  padding: "8px 24px",
  backgroundColor: "$darkGray",
  border: "1px solid #5f6368",
  color: "#e8eaed",
  borderRadius: "4px",
});

const IconButton = styled("button", {
  all: "unset",
  fontFamily: "inherit",
  borderRadius: "100%",
  height: "42px",
  width: "42px",
  display: "inline-flex",
  alignItems: "center",
  justifyContent: "center",
  color: "$white",
  backgroundColor: "white",
  boxShadow: `0 2px 10px $black`,
  "&:hover": { backgroundColor: "$turq" },
  "&:focus": { boxShadow: `0 0 0 2px black` },
});

function Document({
  children,
  title,
}: {
  children: React.ReactNode;
  title?: string;
}) {
  return (
    <HTML lang="en">
      <head>
        <meta charSet="utf-8" />
        <meta name="viewport" content="width=device-width,initial-scale=1" />
        <Meta />
        {title ? <title>{title}</title> : null}
        <Links />
      </head>
      <body>
        {children}
        <Scripts />
        {process.env.NODE_ENV === "development" && <LiveReload />}
      </body>
    </HTML>
  );
}

export function CatchBoundary() {
  const caught = useCatch();

  return (
    <Document title={`${caught.status} ${caught.statusText}`}>
      <div>
        <h1>
          {caught.status} {caught.statusText}
        </h1>
      </div>
    </Document>
  );
}

export function ErrorBoundary({ error }: { error: Error }) {
  console.error(error);

  return (
    <Document title="Uh-oh!">
      <div>
        <h1>App Error</h1>
        <pre>{error.message}</pre>
      </div>
    </Document>
  );
}

const HTML = styled("html", globals);

const ProjectLogo = styled("div", {
  display: "flex",
  alignItems: "center",
  justifyContent: "center",
  gap: "8px",

  ":hover": {
    color: "$blue",
  },
});

const LogoText = styled("h1", {
  fontSize: "36px",
  color: "white",
  fontWeight: "bold",
  alignText: "center",
  fontFamily: "Muli",
});

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
    width: "900px",
    backgroundColor: "$midnight",
    padding: "12px",
  }),
  MenuArea: styled("div", {
    display: "flex",
    gap: "12px",
  }),
};

const Content = styled("div", {
  marginTop: "70px",
  minHeight: "calc(100vh - 50px)",
  display: "flex",
  justifyContent: "center",
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
