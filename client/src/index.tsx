import React from "react";
import ReactDOM from "react-dom";
import App from "./App";
import * as serviceWorker from "./serviceWorker";
import { ApolloProvider } from "@apollo/client";
import { client } from "./apollo";

export const recaptchaSiteKey = process.env.REACT_APP_RECAPTCHA_SITE_KEY || "";
export const backendUrl = process.env.REACT_APP_BACKEND_URL || "";

ReactDOM.render(
  <React.StrictMode>
    <ApolloProvider client={client}>
      <App />
    </ApolloProvider>
  </React.StrictMode>,
  document.getElementById("root")
);

serviceWorker.unregister();
