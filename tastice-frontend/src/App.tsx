import React, { useState, useEffect } from "react";
import { BrowserRouter as Router, Route, Redirect } from "react-router-dom";
import { useQuery, useMutation } from "@apollo/react-hooks";

import { UserList } from "./components/UserList";
import { ProductList } from "./components/ProductList";
import { AddProduct } from "./components/AddProduct";
import { Index } from "./components/Index";
import { Notifications } from "./components/Notification";
import { LogIn } from "./components/LogIn";
import { SignUp } from "./components/SignUp";
import { Navbar } from "./components/Navbar";
import { Product } from "./components/Product";
import { Profile } from "./components/Profile";
import { IProduct } from "./types";
import { ALL_PRODUCTS } from "./queries";

import CssBaseline from "@material-ui/core/CssBaseline";
import { createMuiTheme } from "@material-ui/core/styles";
import { ThemeProvider } from "@material-ui/styles";
import blue from "@material-ui/core/colors/blue";
import pink from "@material-ui/core/colors/pink";

const theme = createMuiTheme({
  palette: {
    type: "dark",
    primary: blue,
    secondary: pink
  }
});

const App = () => {
  const [token, setToken] = useState(null);
  const productsQuery = useQuery(ALL_PRODUCTS);

  useEffect(() => {
    const token: any = localStorage.getItem("token");
    if (token) {
      setToken(token);
    }
  });

  const productById = (id: string) =>
    productsQuery.data.products.find((product: IProduct) => product.id === id);

  if (!token) {
    return (
      <div>
        <ThemeProvider theme={theme}>
          <CssBaseline />
          <Router>
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
          </Router>
        </ThemeProvider>
      </div>
    );
  }

  return (
    <div>
      <ThemeProvider theme={theme}>
        <CssBaseline />
        <Router>
          <Navbar setToken={setToken} />
          <div style={{ padding: 70 }}>
            <Route exact path="/" render={() => <Index />} />
            <Route
              exact
              path="/products"
              render={() => (
                <ProductList products={productsQuery.data.products} />
              )}
            />
            <Route exact path="/users" render={() => <UserList />} />
            <Route exact path="/addproduct" render={() => <AddProduct />} />
            <Route
              exact
              path="/profile"
              render={() => (
                <Profile
                  user={{ name: "Moi", email: "Hei@google.com", id: "id" }}
                />
              )}
            />
            <Route
              exact
              path="/products/:id"
              render={({ match }) => (
                <Product product={productById(match.params.id)} />
              )}
            />
          </div>
        </Router>
      </ThemeProvider>
    </div>
  );
};

export default App;
