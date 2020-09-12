import React, { lazy, Suspense } from "react";
import { Route, Switch } from "react-router-dom";
import { useQuery, gql } from "@apollo/client";
import styled from "styled-components";
import Navigation from "./components/Navigation";

const Home = lazy(() => import("./pages/Home"));
const Activity = lazy(() => import("./pages/Activity"));
const Account = lazy(() => import("./pages/Account"));
const Landing = lazy(() => import("./pages/Landing"));
const SignUp = lazy(() => import("./pages/SignUp"));

const Router = () => {
  const { data, loading } = useQuery(CURRENT_ACCOUNT);

  if (loading) return null;

  return (
    <Suspense fallback={<div>Loading...</div>}>
      <Switch>
        {!data?.currentAccount ? (
          <>
            <Route path="/signup" exact>
              <SignUp />
            </Route>

            <Route path="/" exact>
              <Landing />
            </Route>
          </>
        ) : (
          <>
            <Page>
              <Route path="/" exact>
                <Home />
              </Route>
              <Route path="/activity" exact>
                <Activity />
              </Route>
              <Route path="/account" exact>
                <Account />
              </Route>
            </Page>

            <Navigation />
          </>
        )}
      </Switch>
    </Suspense>
  );
};

const Page = styled.div`
  display: flex;
  justify-content: center;
  min-height: calc(100vh - 50px);
  max-width: 800px;
  margin: 0 auto;
  padding-bottom: env(safe-area-inset-bottom);
`;

const CURRENT_ACCOUNT = gql`
  query IsLoggedIn {
    currentAccount {
      id
    }
  }
`;

export default Router;
