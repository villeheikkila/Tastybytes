import { styled } from "~/stitches.config";

const Container = styled("div", {
  display: "flex",
  flexDirection: "column",
  gap: "4px",
  borderRadius: 6,
  padding: 24,
  width: "min(95vw, 36rem)",
  backdropFilter: "blur(20px)",
  backgroundColor: "rgba(0, 0, 0, 0.8)",
  boxShadow:
    "hsl(206 22% 7% / 35%) 0px 10px 38px -10px, hsl(206 22% 7% / 20%) 0px 10px 20px -15px",
  "@media (prefers-reduced-motion: no-preference)": {
    animationDuration: "400ms",
    animationTimingFunction: "cubic-bezier(0.16, 1, 0.3, 1)",
  },
});

export const Card = {
  Container,
};
