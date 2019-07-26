import React, { useState, useEffect } from 'react';
import { useQuery } from '@apollo/react-hooks';
import { THEME } from './queries';
import { ThemeProvider } from '@material-ui/styles';
import { BrowserRouter as Router, Route, Switch, Redirect } from 'react-router-dom';

import { BottomBar } from './components/BottomBar';
import { UserList } from './components/UserList';
import { ProductList } from './components/ProductList';
import { AddProduct } from './components/AddProduct';
import { Index } from './components/Index';
import { Notifications } from './components/Notification';
import { MobileMenu } from './components/MobileMenu';
import { LogIn } from './components/LogIn';
import { SignUp } from './components/SignUp';
import { NavigationBar } from './components/NavigationBar';
import { ProductView } from './components/ProductView';
import { Account } from './components/Account';
import { ActivityView } from './components/ActivityView';
import { ProductPage } from './components/ProductPage';
import { ProfilePage } from './components/ProfilePage';
import { FriendList } from './components/FriendList';

import { Box, createMuiTheme, Fade, CssBaseline } from '@material-ui/core';
import { blue, pink } from '@material-ui/core/colors';

const darkTheme = createMuiTheme({
    palette: {
        type: 'dark',
        primary: blue,
        secondary: pink,
    },
});

const whiteTheme = createMuiTheme({
    palette: {
        primary: blue,
        secondary: pink,
    },
});

const App = () => {
    const [token, setToken] = useState();
    const [userId, setUserId] = useState();
    const themeSwitcher = useQuery(THEME);
    const theme = themeSwitcher.data.theme ? 1 : 0;
    const themes = [darkTheme, whiteTheme];

    useEffect(() => {
        const token = localStorage.getItem('token');
        const userId = localStorage.getItem('userId');
        if (token) {
            setToken(token);
            setUserId(userId);
        }
    }, [token]);

    return (
        <div>
            <ThemeProvider theme={themes[theme]}>
                <CssBaseline />
                <Router>
                    <Notifications />
                    {!token ? (
                        <Switch>
                            <Route exact path="/" render={() => <LogIn setToken={setToken} />} />
                            <Route exact path="/signup" render={() => <SignUp setToken={setToken} />} />
                            <Route render={() => <LogIn setToken={setToken} />} />
                        </Switch>
                    ) : (
                        <div style={{ paddingTop: 70 }}>
                            <NavigationBar setToken={setToken} />
                            <Fade timeout={300}>
                                <Switch>
                                    <Route exact path="/" render={() => <Index />} />
                                    <Route exact path="/products" render={() => <ProductList />} />
                                    <Route exact path="/discover" render={() => <ProductView />} />
                                    <Route exact path="/users" render={() => <UserList />} />
                                    <Route exact path="/activity" render={() => <ActivityView />} />
                                    <Route exact path="/addproduct" render={() => <AddProduct />} />
                                    <Route exact path="/friends" render={() => <FriendList />} />
                                    <Route exact path="/menu" render={() => <MobileMenu setToken={setToken} />} />
                                    <Route exact path="/account" render={() => <Account setToken={setToken} />} />
                                    <Redirect from="/profile" to={`/user/${userId}`} />
                                    <Route
                                        exact
                                        path="/product/:id"
                                        render={({ match }) => <ProductPage id={match.params.id} />}
                                    />
                                    <Route
                                        exact
                                        path="/product/:id/edit"
                                        render={({ match }) => <ProductPage id={match.params.id} />}
                                    />
                                    <Route
                                        exact
                                        path="/user/:id"
                                        render={({ match }) => <ProfilePage id={match.params.id} />}
                                    />
                                    <Route render={() => <Index />} />
                                </Switch>
                            </Fade>
                            <Box display={{ xs: 'block', md: 'none' }}>
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
