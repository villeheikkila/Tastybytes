import React from "react";
import Routes from "./Routes";
import { BrowserRouter } from "react-router-dom";
import { PortalProvider } from "./components/Portal";
import GlobalStyle from "./theme/globalStyle";
import { ThemeProvider } from "styled-components";
import theme from "./theme";

const App = () => (
  <BrowserRouter>
    <GlobalStyle />
    <ThemeProvider theme={theme}>
      <PortalProvider>
        <Routes />
      </PortalProvider>
    </ThemeProvider>
  </BrowserRouter>
);

export default App;
