import { styled } from "~/stitches.config";

export const Input = styled("input", {
  backdropFilter: "blur(20px)",
  borderRadius: "10px",
  color: "#bababa",
  backgroundColor: "rgba(45, 46, 48, 0.5)",
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
