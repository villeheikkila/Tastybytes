import { styled } from "@pwa/common";

const Wrapper = styled("div", {
  display: "flex",
  flexDirection: "column",
  gap: "4px",
  borderRadius: 6,
  padding: 24,
  width: "min(95vw, 36rem)",

  backgroundColor: "rgba(45, 46, 48, 1.00)",
  boxShadow:
    "hsl(206 22% 7% / 35%) 0px 10px 38px -10px, hsl(206 22% 7% / 20%) 0px 10px 20px -15px",
  "@media (prefers-reduced-motion: no-preference)": {
    animationDuration: "400ms",
    animationTimingFunction: "cubic-bezier(0.16, 1, 0.3, 1)",
  },
});

const Container = styled("div", {
  display: "flex",
  flexDirection: "column",
  gap: "12px",
});

export const Card = {
  Container,
  Wrapper,
};
