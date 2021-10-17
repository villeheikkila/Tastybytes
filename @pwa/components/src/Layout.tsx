import { styled } from "@pwa/common";

const Root = styled("div", {
  display: "flex",
  flexDirection: "column",
  gap: "12px",
  justify: "center",
  alignItems: "center",
});

const Header = styled("header", {
  display: "flex",
  flexDirection: "column",
  justifyContent: "center",
  alignItems: "center",
  gap: "10px",
});

export const Layout = {
  Root,
  Header,
};
