import React, { useState, useEffect } from "react";
import { BrowserRouter as Router, Route, Link } from "react-router-dom";
import { ALL_USERS, ALL_PRODUCTS, LOGIN } from "./queries";

import { UserList } from "./components/UserList";
import { ProductList } from "./components/ProductList";
import { useQuery, useMutation } from "@apollo/react-hooks";
import { AddProduct } from "./components/AddProduct";
import { Index } from "./components/Index";
import { LogIn } from "./components/LogIn";
import { SignUp } from "./components/SignUp";
import { Navbar } from "./components/Navbar";
import { Product } from "./components/Product";
import { Profile } from "./components/Profile";
import { IProduct } from "./types";
import Container from "@material-ui/core/Container";
import CssBaseline from "@material-ui/core/CssBaseline";

import { createMuiTheme } from "@material-ui/core/styles";
import { ThemeProvider } from "@material-ui/styles";

const theme = createMuiTheme({
  palette: {
    type: "dark"
  }
});

const App = () => {
  const [token, setToken] = useState(null);
  const usersQuery = useQuery(ALL_USERS);
  const productsQuery = useQuery(ALL_PRODUCTS);

  useEffect(() => {
    const token: any = localStorage.getItem("token");
    if (token) {
      setToken(token);
    }
  });

  const handleError = (error: any) => {
    console.log("error: ", error);
  };

  const [login] = useMutation(LOGIN, {
    onError: handleError
  });

  const logout = async (
    event: React.FormEvent<HTMLFormElement>
  ): Promise<void> => {
    event.preventDefault();
    setToken(null);
    localStorage.clear();
  };

  if (!token) {
    return (
      <div>
        <Router>
          <Route
            exact
            path="/"
            render={() => <LogIn login={login} setToken={setToken} />}
          />
          <Route
            exact
            path="/signup"
            render={() => <SignUp login={login} setToken={setToken} />}
          />
        </Router>
      </div>
    );
  }

  if (
    usersQuery.data.users === undefined ||
    productsQuery.data.products === undefined
  ) {
    return (
      <div>
        <p>Loading...</p>
      </div>
    );
  }

  const productById = (id: string) =>
    productsQuery.data.products.find((product: IProduct) => product.id === id);

  return (
    <div>
      <ThemeProvider theme={theme}>
        <CssBaseline />
        <Router>
          <Navbar logout={logout} />
          <div style={{ padding: 70 }}>
            <Route exact path="/" render={() => <Index />} />
            <Route
              exact
              path="/products"
              render={() => (
                <ProductList products={productsQuery.data.products} />
              )}
            />
            <Route
              exact
              path="/users"
              render={() => <UserList users={usersQuery.data.users} />}
            />
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
