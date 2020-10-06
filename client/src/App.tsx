import { ApolloProvider } from "@apollo/client";
import React from "react";
import { BrowserRouter } from "react-router-dom";
import { ThemeProvider } from "styled-components";
import { GlobalStyle, ModalProvider, PortalProvider, theme } from "./common";
import { client } from "./common/apollo";
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
