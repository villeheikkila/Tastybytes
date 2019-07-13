import React, { useState, useEffect } from "react";
import { Router, Route, Switch } from "react-router-dom";
import { useQuery } from "@apollo/react-hooks";

import CssBaseline from "@material-ui/core/CssBaseline";
import { createMuiTheme } from "@material-ui/core/styles";
import { ThemeProvider } from "@material-ui/styles";
import blue from "@material-ui/core/colors/blue";
import pink from "@material-ui/core/colors/pink";
import Fade from "@material-ui/core/Fade";
import history from './utils/history';

import { UserList } from "./components/UserList";
import { ProductList } from "./components/ProductList";
import { AddProduct } from "./components/AddProduct";
import { Index } from "./components/Index";
import { Notifications } from "./components/Notification";
import { LogIn } from "./components/LogIn";
import { SignUp } from "./components/SignUp";
import { Navbar } from "./components/Navbar";
import { ProductView } from "./components/ProductView";
import { Profile } from "./components/Profile";
import { THEME } from "./queries";

const darkTheme = createMuiTheme({
  palette: {
    type: "dark",
    primary: blue,
    secondary: pink
  }
});

const whiteTheme = createMuiTheme({
  palette: {
    primary: blue,
    secondary: pink
  }
});

const App = () => {
  const [token, setToken] = useState();
  const themeSwitcher = useQuery(THEME);
  const theme = themeSwitcher.data.theme ? 1 : 0;
  const themes = [darkTheme, whiteTheme];

  useEffect(() => {
    const token = localStorage.getItem("token");
    if (token) {
      setToken(token);
    }
  });

  return (
    <div>
      <ThemeProvider theme={themes[theme]}>
        <CssBaseline />
        <Router history={history}>
          <Notifications />
          {!token ? (
            <Switch>
              <Route
                exact
                path="/"
                render={() => <LogIn setToken={setToken} />}
              />
              <Route
                exact
                path="/signup"
                render={() => <SignUp setToken={setToken} />}
              />
              <Route render={() => <LogIn setToken={setToken} />} />
            </Switch>
          ) : (<div style={{ paddingTop: 100 }}>
            <Navbar setToken={setToken} />
            <Fade timeout={300}>
              <Switch>
                <Route exact path="/" render={() => <Index />} />
                <Route exact path="/products" render={() => <ProductList />} />
                <Route exact path="/productsview" render={() => <ProductView />} />
                <Route exact path="/users" render={() => <UserList />} />
                <Route exact path="/addproduct" render={() => <AddProduct />} />
                <Route exact path="/profile" render={() => <Profile setToken={setToken} />} />
                <Route render={() => <Index />} />
              </Switch>
            </Fade>
          </div>)}
        </Router>
      </ThemeProvider>
    </div >
  );
};

export default App;
