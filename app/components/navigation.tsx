import { Form } from "remix";
import { styled } from "~/stitches.config";

const Header = styled("header", {
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
});

export const Navigation = () => {
  return (
    <Header>
      <Content>
        <ProjectLogo>
          <img
            color="white"
            alt="project logo"
            src="/favicon.svg"
            height={32}
            width={32}
          />
          <LogoText>Tasted</LogoText>
        </ProjectLogo>
        <Search />
      </Content>
    </Header>
  );
};

export const Search = () => {
  return (
    <Form method="get" action="/search">
      <Input id="search" name="term" type="text" placeholder="Search..." />
      <button type="submit">Search</button>
    </Form>
  );
};

export const Content = styled("div", {
  display: "flex",
  justifyContent: "space-between",
  alignItems: "center",
  width: "900px",
  backgroundColor: "$midnight",
  padding: "12px",
});

export const Input = styled("input", {
  backgroundColor: "#333333",
  borderRadius: "10px",
  color: "#bababa",
  display: "inline-block",
  padding: "0px 16px",
  fontSize: "16px",
  height: "40px",
  border: "none",
  "&:focus": { outline: "1px solid $blue" },
  transition: "outline 0.4s ease 0s, color 0.2s ease 0s",
  "&[aria-invalid='true']": {
    outline: "1px solid red",
  },
});

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
