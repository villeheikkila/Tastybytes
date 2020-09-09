import React, { lazy, Suspense } from "react";
import { Route, Switch } from "react-router-dom";
import { useQuery, gql } from "@apollo/client";

const Home = lazy(() => import("./pages/Home"));
const Landing = lazy(() => import("./pages/Landing"));
const SignUp = lazy(() => import("./pages/SignUp"));

const Router = () => {
  const { data } = useQuery(CURRENT_ACCOUNT);
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <Switch>
        {!data?.currentAccount ? (
          <>
            <Route path="/" exact>
              <Landing />
            </Route>

            <Route path="/signup" exact>
              <SignUp />
            </Route>
          </>
        ) : (
          <>
            <Route path="/" exact>
              <Home />
            </Route>
            <Route path="/signup" exact>
              <SignUp />
            </Route>
          </>
        )}
      </Switch>
    </Suspense>
  );
};

const CURRENT_ACCOUNT = gql`
  query CurrentAccount {
    currentAccount {
      id
    }
  }
`;

export default Router;
