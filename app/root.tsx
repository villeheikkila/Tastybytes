import {
  Link,
  Links,
  LiveReload,
  Meta, MetaFunction, Outlet,
  Scripts,
  ScrollRestoration
} from "remix";
import { globals, styled } from "./stitches.config";

export const meta: MetaFunction = () => {
  return { title: "Tasted" };
};

export default function App() {
  return (
    <HTML lang="en">
      <head>
        <meta charSet="utf-8" />
        <meta name="viewport" content="width=device-width,initial-scale=1" />
        <Meta />
        <Links />
      </head>
      <body>
      <Navigation.Header>
        <Navigation.Content>
          <Link to="/">
            <ProjectLogo>
              <img color="white" src="/maku.svg" height={32} width={32} />
              <LogoText>Tasted</LogoText>
            </ProjectLogo>
          </Link>
        </Navigation.Content>
      </Navigation.Header>
        <Content>
          <Outlet />
        </Content>
        <Footer.Wrapper>
        <Footer.Content>
          <p>
            Copyright &copy; {new Date().getFullYear()} Ville Heikkilä. All
            rights reserved.
          </p>
        </Footer.Content>
      </Footer.Wrapper>
        <ScrollRestoration />
        <Scripts />
        {process.env.NODE_ENV === "development" && <LiveReload />}
      </body>
    </HTML>
  );
}

const HTML = styled("html", globals)

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
    display: "flex", gap: "12px"
  })
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
