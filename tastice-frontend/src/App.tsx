import { useQuery, useSubscription } from '@apollo/react-hooks';
import { createMuiTheme, CssBaseline } from '@material-ui/core';
import { blue, pink } from '@material-ui/core/colors';
import { ThemeProvider } from '@material-ui/styles';
import { useLocalStorage } from '@rehooks/local-storage';
import React from 'react';
import { Routes } from './components/Routes';
import { ME } from './graphql';
import { FRIENDREQUEST_SUBSCRIPTION } from './graphql/user';
import { notificationHandler } from './utils';

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

export const App = (): JSX.Element => {
    const me = useQuery(ME);
    const [user] = useLocalStorage<LocalStorageUser>('user');

    const id = (user && user.id) || '';

    const theme = (id && me.data.me && me.data.me.colorScheme) || 0;
    const themes = [darkTheme, whiteTheme];

    const { data } = useSubscription(FRIENDREQUEST_SUBSCRIPTION, {
        variables: { id },
    });

    if (data && data.friendRequest.node && data.friendRequest.node.sender[0]) {
        notificationHandler({
            message: `Friend request recieved from ${data.friendRequest.node.sender[0].firstName}!`,
            variant: 'success',
        });
    }

    return (
        <ThemeProvider theme={themes[theme]}>
            <CssBaseline />
            <Routes />
        </ThemeProvider>
    );
};
