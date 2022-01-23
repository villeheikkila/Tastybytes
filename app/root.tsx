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
import { globals, styled } from "./stitches.config";
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
        {data?.user ? (
          <div className="user-info">
            <span>{data.user.username}</span>
            <Form action="/logout" method="post">
              <button type="submit" className="button">
                Logout
              </button>
            </Form>
          </div>
        ) : (
          <Link to="/login">Login</Link>
        )}
      </Navigation.Content>
    </Navigation.Header>
  );
};

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
      <div className="error-container">
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
      <div className="error-container">
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
