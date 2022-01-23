import { createStitches, globalCss } from "@stitches/react";

export const { styled, getCssText, keyframes } = createStitches({
  theme: {
    colors: {
      black: "rgba(19, 19, 21, 1)",
      white: "#e8eaed",
      gray: "rgba(128, 128, 128, 1)",
      blue: "rgba(0, 153, 254, 1.00)",
      red: "rgba(249, 16, 74, 1)",
      yellow: "rgba(255, 221, 0, 1)",
      pink: "rgba(232, 141, 163, 1)",
      turq: "rgba(0, 245, 196, 1)",
      orange: "rgba(255, 135, 31, 1)",
      midnight: "rgba(24, 24, 24, 1.00)",
      darkGray: "rgba(45, 46, 48, 1.00)",
    },
    fonts: {
      sans: "Inter, sans-serif",
    },
    fontSizes: {
      1: "12px",
      2: "14px",
      3: "16px",
      4: "20px",
      5: "24px",
      6: "32px",
    },
    space: {
      1: "4px",
      2: "8px",
      3: "16px",
      4: "32px",
      5: "64px",
      6: "128px",
    },
    sizes: {
      1: "4px",
      2: "8px",
      3: "16px",
      4: "32px",
      5: "64px",
      6: "128px",
    },
    radii: {
      1: "2px",
      2: "4px",
      3: "8px",
      round: "9999px",
    },
    fontWeights: {},
    lineHeights: {},
    letterSpacings: {},
    borderWidths: {},
    borderStyles: {},
    shadows: {},
    zIndices: {},
    transitions: {},
  },
});

export const globals = {
  "*:where(:not(iframe, canvas, img, svg, video):not(svg *))": {
    all: "unset",
    display: "revert",
  },
  "*, *::before, *::after": { boxSizing: "border-box" },
  "ol, ul": { listStyle: "none" },
  img: { maxWidth: "100%" },
  table: { borderCollapse: "collapse" },
  textarea: { whiteSpace: "revert" },
  html: {
    blockSize: "100%",
  },
  body: {
    minBlockSize: "100%",
    background: "$midnight",
    color: "$white",
    fontFamily:
      '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol"',
  },
};

export const globalStyles = globalCss(globals);
