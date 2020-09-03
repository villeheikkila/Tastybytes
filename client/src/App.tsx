import React from "react";
import { useQuery, gql } from "@apollo/client";
import Routes from "./Router";
import { BrowserRouter } from "react-router-dom";

const App = () => {
  return (
    <BrowserRouter>
      <Routes />
    </BrowserRouter>
  );
};

export default App;
