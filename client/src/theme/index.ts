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
  typography: {
    fontSizes: ["2.369rem", "1.777rem", "1.333rem"],
    body: {
      fontFamily:
        "system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen', 'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue', sans-serif",
      size: 3,
      fontWeight: 500,
      color: colors.white,
      lineHeight: 1.4,
    },
    heading: {
      fontFamily:
        "system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen', 'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue', sans-serif",
      size: 1,
      fontWeight: 700,
      color: colors.white,
      lineHeight: 1.2,
    },
    link: {
      color: colors.blue,
      fontWeight: 600,
    },
  },
  borderRadius: "8px",
};

export default theme;
