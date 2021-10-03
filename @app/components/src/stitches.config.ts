import { createStitches, globalCss } from "@stitches/react";

export const { styled, getCssText, keyframes } = createStitches({
  theme: {
    colors: {
      black: "rgba(19, 19, 21, 1)",
      white: "rgba(255, 255, 255, 1)",
      gray: "rgba(128, 128, 128, 1)",
      blue: "rgba(0, 153, 254, 1.00)",
      red: "rgba(249, 16, 74, 1)",
      yellow: "rgba(255, 221, 0, 1)",
      pink: "rgba(232, 141, 163, 1)",
      turq: "rgba(0, 245, 196, 1)",
      orange: "rgba(255, 135, 31, 1)",
      midnight: "rgba(24, 24, 24, 1.00)",
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

export const globalStyles = globalCss({
  "html, body, div, span, applet, object, iframe, h1, h2, h3, h4, h5, h6, p, blockquote, pre, a, abbr, acronym, address, big, cite, code, del, dfn, em, img, ins, kbd, q, s, samp, small, strike, strong, sub, sup, tt, var, b, u, i, center, dl, dt, dd, ol, ul, li, fieldset, form, label, legend, table, caption, tbody, tfoot, thead, tr, th, td, article, aside, canvas, details, embed, figure, figcaption, footer, header, hgroup, main, menu, nav, output, ruby, section, summary, time, mark, audio, video":
    {
      margin: 0,
      padding: 0,
      border: 0,
      fontSize: "100%",
      font: "inherit",
      verticalAlign: "baseline",
      boxSizing: "border-box",
      color: "$white",
    },
  "article, aside, details, figcaption, figure, footer, header, hgroup, main, menu, nav, section":
    {
      display: "block",
    },
  "*[hidden]": {
    display: "none",
  },
  body: {
    lineHeight: "1",
    backgroundColor: "$midnight",
  },
  "ol, ul": {
    listStyle: "none",
  },
  "blockquote, q": {
    quotes: "none",
  },
  "blockquote:before, blockquote:after, q:before, q:after": {
    content: "",
    // @ts-ignore
    content: "none",
  },
  table: {
    borderSpacing: 0,
  },
  h1: {
    fontFamily: "Muli",
    fontSize: "24px",
    fontStyle: "normal",
    fontVariant: "normal",
    fontWeight: 700,
    lineHeight: "26.4px",
  },
  h3: {
    fontFamily: "Muli",
    fontSize: "14px",
    fontStyle: "normal",
    fontVariant: "normal",
    fontWeight: 700,
    lineHeight: "15.4px",
  },
  a: {
    fontFamily: "Muli",
    fontSize: "14px",
    fontStyle: "normal",
    fontVariant: "normal",
    fontWeight: 500,
    lineHeight: "20px",
    textDecoration  : "none",
    color: "rgba(0, 153, 254, 1.00)"
  },
  p: {
    fontFamily: "Muli",
    fontSize: "14px",
    fontStyle: "normal",
    fontVariant: "normal",
    fontWeight: 400,
    lineHeight: "20px",
  },
  em: {
    fontFamily: "Muli",
    fontSize: "14px",
    fontStyle: "normal",
    fontVariant: "normal",
    fontWeight: 600,
    lineHeight: "20px",
  },
  label: {
    fontFamily: "Muli",
    fontSize: "14px",
    fontStyle: "normal",
    fontVariant: "normal",
    fontWeight: 400,
    lineHeight: "20px",
  },
  blockquote: {
    fontFamily: "Muli",
    fontSize: "21px",
    fontStyle: "normal",
    fontVariant: "normal",
    fontWeight: 400,
    lineHeight: "30px",
  },
  pre: {
    fontFamily: "Muli",
    fontSize: "13px",
    fontStyle: "normal",
    fontVariant: "normal",
    fontWeight: 400,
    lineHeight: "18.5714px",
  },
});
