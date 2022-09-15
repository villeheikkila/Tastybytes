const konstaConfig = require("konsta/config");

module.exports = konstaConfig({
  colors: {
    primary: "#007aff",
    "brand-primary": "#007aff",
    red: "#ff3b30",
    "brand-green": "#4cd964",
    "brand-yellow": "#ffcc00",
    "brand-purple": "#9c27b0",
    "brand-blue": "#2196f3",
  },
  content: [
    "./pages/**/*.{js,ts,jsx,tsx}",
    "./components/**/*.{js,ts,jsx,tsx}",
  ],
  darkMode: "class", // or 'class'
  theme: {
    extend: {},
  },
  variants: {
    extend: {},
  },
  plugins: [],
});
