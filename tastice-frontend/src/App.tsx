import React, { useState, useEffect } from "react";
import { Router, Route, Switch } from "react-router-dom";
import { useQuery } from "@apollo/react-hooks";

import CssBaseline from "@material-ui/core/CssBaseline";
import { createMuiTheme } from "@material-ui/core/styles";
import { ThemeProvider } from "@material-ui/styles";
import blue from "@material-ui/core/colors/blue";
import pink from "@material-ui/core/colors/pink";
import Fade from "@material-ui/core/Fade";
import Box from "@material-ui/core/Box";
import history from "./utils/history";
import { BottomBar } from "./components/BottomBar";
import "typeface-leckerli-one";

import { UserList } from "./components/UserList";
import { ProductList } from "./components/ProductList";
import { AddProduct } from "./components/AddProduct";
import { Index } from "./components/Index";
import { Notifications } from "./components/Notification";
import { MobileMenu } from "./components/MobileMenu";
import { LogIn } from "./components/LogIn";
import { SignUp } from "./components/SignUp";
import { NavigationBar } from "./components/NavigationBar";
import { ProductView } from "./components/ProductView";
import { Account } from "./components/Account";
import { THEME } from "./queries";
import { ActivityView } from "./components/ActivityView";
import { CreateCheckIn } from "./components/CreateCheckIn";
import { MyProfile } from "./components/MyProfile";
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
  }, [token]);

  console.log("token: ", token);

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
          ) : (
            <div style={{ paddingTop: 70 }}>
              <NavigationBar setToken={setToken} />
              <Fade timeout={300}>
                <Switch>
                  <Route exact path="/" render={() => <Index />} />
                  <Route
                    exact
                    path="/products"
                    render={() => <ProductList />}
                  />
                  <Route
                    exact
                    path="/discover"
                    render={() => <ProductView />}
                  />
                  <Route exact path="/users" render={() => <UserList />} />
                  <Route
                    exact
                    path="/activity"
                    render={() => <ActivityView />}
                  />
                  <Route
                    exact
                    path="/addproduct"
                    render={() => <AddProduct />}
                  />
                  <Route
                    exact
                    path="/menu"
                    render={() => <MobileMenu setToken={setToken} />}
                  />
                  <Route
                    exact
                    path="/account"
                    render={() => <Account setToken={setToken} />}
                  />
                  <Route exact path="/myprofile" render={() => <MyProfile />} />
                  <Route
                    exact
                    path="/product/:id"
                    render={({ match }) => (
                      <CreateCheckIn id={match.params.id} />
                    )}
                  />
                  <Route render={() => <Index />} />
                </Switch>
              </Fade>
              <Box display={{ xs: "block", md: "none" }}>
                <BottomBar />
              </Box>
            </div>
          )}
        </Router>
      </ThemeProvider>
    </div>
  );
};

export default App;
