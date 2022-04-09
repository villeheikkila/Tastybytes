import { styled } from "@nextui-org/react";

export const StyledBadge = styled("span", {
  display: "inline-block",
  textTransform: "uppercase",
  padding: "2px",
  margin: "0 2px",
  fontSize: "10px",
  fontWeight: 500,
  borderRadius: "14px",
  letterSpacing: "0.6px",
  lineHeight: 1,
  boxShadow: "1px 2px 5px 0px rgb(0 0 0 / 5%)",
  alignItems: "center",
  alignSelf: "center",
  color: "#fff",
  variants: {
    type: {
      active: {
        bg: "green",
        color: "green",
      },
      paused: {
        bg: "red",
        color: "red",
      },
      vacation: {
        bg: "fff",
        color: "red",
      },
    },
  },
  defaultVariants: {
    type: "active",
  },
});
