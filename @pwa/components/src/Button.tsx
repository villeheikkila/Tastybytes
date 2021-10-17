import { styled } from "@pwa/common";

export const Button = styled("button", {
  backgroundColor: "#0099ff",
  borderRadius: "10px",
  boxShadow: "#000000 0px 1px 2px 0px",
  color: "#ffffff",
  fontSize: "16px",
  fontWeight: 500,
  lineHeight: "15px",
  padding: "0px 16px",
  textAlign: "center",
  height: "40px",
  border: "none",
  variants: {
    variant: {
      warning: {
        backgroundColor: "$red",
      },
    },
  },
});
