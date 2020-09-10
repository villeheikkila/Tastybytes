import React from "react";
import Routes from "./Routes";
import { BrowserRouter } from "react-router-dom";
import { PortalProvider } from "./components/Portal";

const App = () => (
  <BrowserRouter>
    <PortalProvider>
      <Routes />
    </PortalProvider>
  </BrowserRouter>
);

export default App;
