import React, { useState, useEffect } from "react";
import { BrowserRouter as Router, Route, Switch } from "react-router-dom";
import { useQuery } from "@apollo/react-hooks";

import { UserList } from "./components/UserList";
import { ProductList } from "./components/ProductList";
import { AddProduct } from "./components/AddProduct";
import { Index } from "./components/Index";
import { Notifications } from "./components/Notification";
import { LogIn } from "./components/LogIn";
import { SignUp } from "./components/SignUp";
import { Navbar } from "./components/Navbar";
import { Profile } from "./components/Profile";
import { THEME } from "./queries";
import CssBaseline from "@material-ui/core/CssBaseline";
import { createMuiTheme } from "@material-ui/core/styles";
import { ThemeProvider } from "@material-ui/styles";
import blue from "@material-ui/core/colors/blue";
import pink from "@material-ui/core/colors/pink";
import Fade from "@material-ui/core/Fade";

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
  const [token, setToken] = useState(null);
  const themeSwitcher = useQuery(THEME);
  const theme = themeSwitcher.data.theme ? 1 : 0;

  useEffect(() => {
    const token: any = localStorage.getItem("token");
    if (token) {
      setToken(token);
    }
  });

  const themes: any = [darkTheme, whiteTheme];

  return (
    <div>
      <ThemeProvider theme={themes[theme]}>
        <CssBaseline />
        <Router>
          <Notifications />
          {!token ? (<Router>
            <Notifications />
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
          </Router>) : (<div style={{ padding: 100 }}>
            <Navbar setToken={setToken} />
            <Fade timeout={300}>
              <Switch>
                <Route exact path="/" render={() => <Index />} />
                <Route exact path="/products" render={() => <ProductList />} />
                <Route exact path="/users" render={() => <UserList />} />
                <Route exact path="/addproduct" render={() => <AddProduct />} />
                <Route exact path="/profile" render={() => <Profile />} />
                <Route render={() => <Index />} />
              </Switch>
            </Fade>
          </div>)}

        </Router>
      </ThemeProvider>
    </div>
  );
};

export default App;
