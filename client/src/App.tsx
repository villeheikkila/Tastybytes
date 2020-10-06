import React from "react";
import Routes from "./Routes";
import { BrowserRouter } from "react-router-dom";
import GlobalStyle from "./theme/globalStyle";
import { ThemeProvider } from "styled-components";
import theme from "./theme/theme";
import PortalProvider from "./common/providers/PortalProvider";
import ModalProvider from "./common/providers/ModalProvider";

const App = () => (
  <BrowserRouter>
    <GlobalStyle />
    <ThemeProvider theme={theme}>
      <PortalProvider>
        <ModalProvider>
          <Routes />
        </ModalProvider>
      </PortalProvider>
    </ThemeProvider>
  </BrowserRouter>
);

export default App;
