import React, { lazy, Suspense } from "react";
import { Route, Switch } from "react-router-dom";

const Landing = lazy(() => import("./pages/Landing"));
const SignUp = lazy(() => import("./pages/SignUp"));

const Router = () => (
  <Suspense fallback={<div>Loading...</div>}>
    <Switch>
      <Route path="/" exact>
        <Landing />
      </Route>

      <Route path="/signup" exact>
        <SignUp />
      </Route>
    </Switch>
  </Suspense>
);

export default Router;
