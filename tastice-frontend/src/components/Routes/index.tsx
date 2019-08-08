import { Box, Fade } from '@material-ui/core';
import React, { useContext } from 'react';
import { BrowserRouter as Router, Redirect, Route, Switch } from 'react-router-dom';
import { UserContext } from '../../App';
import { Account } from '../../scenes/Account';
import { Activity } from '../../scenes/Activity';
import { Dashboard } from '../../scenes/Dashboard';
import { Discover } from '../../scenes/Discover';
import { LogIn } from '../../scenes/LogIn';
import { Product } from '../../scenes/Product';
import { Profile } from '../../scenes/Profile';
import { SignUp } from '../../scenes/SignUp';
import { AddProduct } from '../AddProduct';
import { BottomBar } from '../BottomBar';
import { FriendList } from '../FriendList';
import { MobileMenu } from '../MobileMenu';
import { NavigationBar } from '../NavigationBar/';
import { Notifications } from '../Notification';
export const Routes = (): JSX.Element => {
    const { id, token } = useContext(UserContext);

    return (
        <Router>
            <Notifications />
            {!token ? (
                <Switch>
                    <Route exact path="/" render={(): JSX.Element => <LogIn />} />
                    <Route exact path="/signup" render={(): JSX.Element => <SignUp />} />
                    <Route render={(): JSX.Element => <LogIn />} />
                </Switch>
            ) : (
                <div style={{ paddingTop: 70 }}>
                    <NavigationBar />
                    <Fade timeout={300}>
                        <Switch>
                            <Route exact path="/discover" component={Discover} />
                            <Route exact path="/activity" component={Activity} />
                            <Route exact path="/product/new" component={AddProduct} />
                            <Route exact path="/friends" component={FriendList} />
                            <Route exact path="/menu" component={MobileMenu} />
                            <Route exact path="/account" component={Account} />
                            <Route exact path="/dashboard" component={Dashboard} />
                            <Redirect from="/profile" to={`/user/${id}`} />
                            <Route
                                exact
                                path="/product/:id"
                                render={({ match }): JSX.Element => <Product id={match.params.id} />}
                            />
                            <Route
                                exact
                                path="/user/:id"
                                render={({ match }): JSX.Element => <Profile id={match.params.id} />}
                            />
                            <Redirect from="/" to="/activity" />
                            <Route component={Activity} />
                        </Switch>
                    </Fade>
                    <Box display={{ xs: 'block', md: 'none' }}>
                        <BottomBar />
                    </Box>
                </div>
            )}
        </Router>
    );
};
