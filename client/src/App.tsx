import { ApolloProvider } from "@apollo/client";
import React from "react";
import { BrowserRouter } from "react-router-dom";
import { ThemeProvider } from "styled-components";
import { client } from "./common/apollo";
import ModalProvider from "./common/providers/ModalProvider";
import PortalProvider from "./common/providers/PortalProvider";
import GlobalStyle from "./common/theme/globalStyle";
import theme from "./common/theme/theme";
import Routes from "./Routes";

const App = () => (
  <ApolloProvider client={client}>
    <ThemeProvider theme={theme}>
      <BrowserRouter>
        <GlobalStyle />
        <PortalProvider>
          <ModalProvider>
            <Routes />
          </ModalProvider>
        </PortalProvider>
      </BrowserRouter>
    </ThemeProvider>
  </ApolloProvider>
);

export default App;
