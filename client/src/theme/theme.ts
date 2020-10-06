import { css as cssDefault, ThemedCssFunction } from "styled-components";

/* Hack to avoid conflict where theme references itself through DefaultTheme */
const css = cssDefault as ThemedCssFunction<any>;

const colors = {
  backgroundColor: "rgba(32, 34, 38, 1.0)",
  primary: "rgba(22, 24, 24)",
  white: "rgba(255, 255, 255, 0.847)",
  blue: "rgba(10, 132, 255, 1.0)",
  green: "rgba(50, 215, 75, 1.0)",
  orange: "rgba(255, 159, 10, 1.0)",
  red: "rgba(255, 69, 58, 1.0)",
  yellow: "rgba(255, 214, 10, 1.0)",
  clear: "rgba(0, 0, 0, 0.0)",
  black: "rgba(0, 0, 0, 1.0)",
  cyan: "rgba(0, 255, 255, 1.0)",
  darkGray: "rgba(255, 255, 255, 0.247)",
  gray: "rgba(128, 128, 128, 1.0)",
  magenta: "rgba(255, 0, 255, 1.0)",
  purple: "rgba(128, 0, 128, 1.0)",
};

const theme = {
  colors,
  borderRadius: "8px",
  typography: {
    heading: css`
      font-size: 2.3rem;
      font-weight: 700;
      line-height: 1.2;
    `,
    body: css`
      font-size: 1rem;
      font-weight: 500;
      line-height: 1.4;
    `,
    link: css`
      color: ${colors.blue};
      font-weight: 600;
    `,
  },
};

export default theme;
