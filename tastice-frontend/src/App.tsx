import { useQuery } from '@apollo/react-hooks';
import { Box, createMuiTheme, CssBaseline, Fade } from '@material-ui/core';
import { blue, pink } from '@material-ui/core/colors';
import { ThemeProvider } from '@material-ui/styles';
import React, { useEffect, useState } from 'react';
import { BrowserRouter as Router, Redirect, Route, Switch } from 'react-router-dom';
import { AddProduct } from './components/AddProduct';
import { BottomBar } from './components/BottomBar';
import { FriendList } from './components/FriendList';
import { MobileMenu } from './components/MobileMenu';
import { NavigationBar } from './components/NavigationBar/';
import { Notifications } from './components/Notification';
import { THEME } from './queries';
import { Account } from './scenes/Account';
import { Activity } from './scenes/Activity';
import { Discover } from './scenes/Discover';
import { LogIn } from './scenes/LogIn';
import { Product } from './scenes/Product';
import { ProductList } from './scenes/ProductList';
import { Profile } from './scenes/Profile';
import { SignUp } from './scenes/SignUp';
import { UserList } from './scenes/UserList';

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

const App = (): JSX.Element => {
    const [token, setToken] = useState();
    const [userId, setUserId] = useState();
    const themeSwitcher = useQuery(THEME);
    const theme = themeSwitcher.data.theme ? 1 : 0;
    const themes = [darkTheme, whiteTheme];

    useEffect((): void => {
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
                            <Route exact path="/" render={(): JSX.Element => <LogIn setToken={setToken} />} />
                            <Route exact path="/signup" render={(): JSX.Element => <SignUp setToken={setToken} />} />
                            <Route render={(): JSX.Element => <LogIn setToken={setToken} />} />
                        </Switch>
                    ) : (
                        <div style={{ paddingTop: 70 }}>
                            <NavigationBar setToken={setToken} />
                            <Fade timeout={300}>
                                <Switch>
                                    <Route exact path="/products" render={(): JSX.Element => <ProductList />} />
                                    <Route exact path="/discover" render={(): JSX.Element => <Discover />} />
                                    <Route exact path="/users" render={(): JSX.Element => <UserList />} />
                                    <Route exact path="/activity" render={(): JSX.Element => <Activity />} />
                                    <Route exact path="/product/new" render={(): JSX.Element => <AddProduct />} />
                                    <Route
                                        exact
                                        path="/friends"
                                        render={(): JSX.Element => <FriendList id={userId} />}
                                    />
                                    <Route
                                        exact
                                        path="/menu"
                                        render={(): JSX.Element => <MobileMenu setToken={setToken} />}
                                    />
                                    <Route
                                        exact
                                        path="/account"
                                        render={(): JSX.Element => <Account setToken={setToken} />}
                                    />
                                    <Redirect from="/profile" to={`/user/${userId}`} />
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
                                    <Route render={(): JSX.Element => <Activity />} />
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
