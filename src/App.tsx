import { useApolloClient, useQuery, useSubscription } from '@apollo/react-hooks';
import { createMuiTheme, CssBaseline } from '@material-ui/core';
import { blue, pink } from '@material-ui/core/colors';
import { ThemeProvider } from '@material-ui/styles';
import { useLocalStorage } from '@rehooks/local-storage';
import React from 'react';
import { Routes } from './components/Routes';
import { ME } from './graphql';
import { FRIENDREQUEST_SUBSCRIPTION } from './graphql/user';

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
    const client = useApolloClient();
    const me = useQuery(ME);
    console.log('Site should be loading...');

    const [user] = useLocalStorage<LocalStorageUser>('user');
    const id = user && user.id;
    const { data } = useSubscription(FRIENDREQUEST_SUBSCRIPTION, {
        variables: { id },
    });

    const theme = (id && me && me.data && me.data.me && me.data.me.colorScheme) || 0;
    const themes = [darkTheme, whiteTheme];

    if (data && data.friendRequest.node && data.friendRequest.node.sender[0]) {
        client.writeData({
            data: {
                notification: `Friend request recieved from ${data.friendRequest.node.sender[0].firstName}!`,
                variant: 'success',
            },
        });
    }

    return (
        <ThemeProvider theme={themes[theme]}>
            <CssBaseline />
            <Routes />
        </ThemeProvider>
    );
};
