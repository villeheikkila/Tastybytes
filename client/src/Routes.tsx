import React, { lazy, Suspense } from "react";
import { Route, Switch } from "react-router-dom";
import { useQuery, gql } from "@apollo/client";
import styled from "styled-components";
import Navigation from "./components/Navigation";
import { IsLoggedIn } from "./generated/IsLoggedIn";
import Spinner from "./components/Spinner";

const Home = lazy(() => import("./pages/Home"));
const Treats = lazy(() => import("./pages/Treats"));
const Account = lazy(() => import("./pages/Account"));
const Landing = lazy(() => import("./pages/Landing"));
const SignUp = lazy(() => import("./pages/SignUp"));
const AddTreat = lazy(() => import("./pages/AddTreat"));
const AddReview = lazy(() => import("./pages/AddReview"));
const VerifyAccount = lazy(() => import("./pages/VerifyAccount"));

const Router = () => {
  const { data, loading } = useQuery<IsLoggedIn>(CURRENT_ACCOUNT);

  if (loading) return null;

  return (
    <Suspense fallback={<Spinner />}>
      <Switch>
        <Route path="/verify-email/:token" exact>
          <VerifyAccount />
        </Route>
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
              <Route path="/treats" exact>
                <Treats />
              </Route>
              <Route path="/account" exact>
                <Account />
              </Route>
              <Route path="/treats/add" exact>
                <AddTreat />
              </Route>

              <Route path="/treats/add-review/:id" exact>
                <AddReview />
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
  min-height: calc(100vh - 60px);
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
