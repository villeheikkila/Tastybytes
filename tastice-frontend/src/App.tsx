import { useQuery, useSubscription } from '@apollo/react-hooks';
import { createMuiTheme, CssBaseline } from '@material-ui/core';
import { blue, pink } from '@material-ui/core/colors';
import { ThemeProvider } from '@material-ui/styles';
import React, { createContext, useEffect, useState } from 'react';
import { Routes } from './components/Routes';
import { ME } from './graphql';
import { FRIENDREQUEST_SUBSCRIPTION } from './graphql/user';
import { notificationHandler } from './utils'

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

interface UserContext {
    token: string;
    setToken: React.Dispatch<string | null>;
    id: string;
}

export const App = (): JSX.Element => {
    const [token, setToken] = useState();
    const [id, setId] = useState();
    const me = useQuery(ME);
    const theme = ((token && me.data.me) && me.data.me.colorScheme) || 0;
    const themes = [darkTheme, whiteTheme];

    const { data, loading } = useSubscription(
        FRIENDREQUEST_SUBSCRIPTION,
        { variables: { id } }
    );

    if (data && data.friendRequest.node && data.friendRequest.node.sender[0]) {
        notificationHandler({
            message: `Friend request recieved from ${data.friendRequest.node.sender[0].firstName}!`,
            variant: 'success',
        });
        console.log('friendRequestSubscription: ', data.friendRequest.node)
    }



    useEffect((): void => {
        const token = localStorage.getItem('token');
        const userId = localStorage.getItem('id');
        if (token) {
            setToken(token);
            setId(userId);
        }
    }, [token]);

    return (
        <ThemeProvider theme={themes[theme]}>
            <CssBaseline />
            <UserContext.Provider value={{ setToken, token, id }}>
                <Routes />
            </UserContext.Provider>
        </ThemeProvider>
    );
};

export const UserContext = createContext<UserContext>({
    id: '',
    token: '',
    setToken: () => { },
});
