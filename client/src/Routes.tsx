import React, { lazy, Suspense } from "react";
import { Route, Switch } from "react-router-dom";
import styled from "styled-components";
import { useIsLoggedInQuery } from "./common/queries/queries.hooks";
import { Navigation, Spinner } from "./components";

const Activity = lazy(() => import("./scenes/Activity/Activity"));
const Treats = lazy(() => import("./scenes/Treats/Treats"));
const Account = lazy(() => import("./scenes/Account/Account"));
const AddTreat = lazy(() => import("./scenes/AddTreat/AddTreat"));
const AddReview = lazy(() => import("./scenes/AddReview/AddReview"));

const VerifyAccount = lazy(
  () => import("./landing/VerifyAccount/VerifyAccount")
);
const PasswordReset = lazy(
  () => import("./landing/PasswordReset/PasswordReset")
);
const CheckInbox = lazy(() => import("./landing/CheckInbox/CheckInbox"));
const Landing = lazy(() => import("./landing/Landing/Landing"));
const SignUp = lazy(() => import("./landing/SignUp/SignUp"));

const Router = () => {
  const { data, loading } = useIsLoggedInQuery();

  if (loading) return null;

  return (
    <Suspense fallback={<Spinner />}>
      <GlobalRoutes />
      <Switch>
        {!data?.currentAccount ? <UnauthorizedRoutes /> : <AuthorizedRoutes />}
      </Switch>
    </Suspense>
  );
};

const GlobalRoutes = () => (
  <>
    <Route path="/verify-account/:token" exact>
      <VerifyAccount />
    </Route>
    <Route path="/password-reset/:token" exact>
      <PasswordReset />
    </Route>
  </>
);

const UnauthorizedRoutes = () => (
  <>
    <Route path="/signup" exact>
      <SignUp />
    </Route>

    <Route path="/" exact>
      <Landing />
    </Route>

    <Route path="/email-sent" exact>
      <CheckInbox />
    </Route>
  </>
);

const AuthorizedRoutes = () => (
  <>
    <Page>
      <Route path="/" exact>
        <Activity />
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
);

const Page = styled.div`
  display: flex;
  justify-content: center;
  min-height: calc(100vh - 70px);
  max-width: 800px;
  margin: 0 auto;
`;

export default Router;
