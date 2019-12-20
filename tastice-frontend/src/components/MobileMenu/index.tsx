import { useMutation, useQuery } from '@apollo/react-hooks';
import {
    createStyles,
    Divider,
    List,
    ListItem,
    ListItemText,
    makeStyles,
    Switch,
    Theme,
    Typography,
} from '@material-ui/core';
import useLocalStorage, { deleteFromStorage } from '@rehooks/local-storage';
import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { ME, UPDATE_USER } from '../../graphql';

const useStyles = makeStyles((theme: Theme) =>
    createStyles({
        container: {
            marginTop: 15,
        },
        root: {
            marginTop: 15,
            width: '100%',
            backgroundColor: theme.palette.background.paper,
        },
    }),
);

export const MobileMenu = (): JSX.Element => {
    const classes = useStyles({});
    const [colorScheme, setColorScheme] = useState(false);
    const { data, client } = useQuery(ME);
    const { me } = data;

    const [updateUser] = useMutation(UPDATE_USER, {
        onError: error => {
            client.writeData({
                data: {
                    notification: error.message,
                    variant: 'error',
                },
            });
        },
        refetchQueries: [{ query: ME }],
    });

    const [user] = useLocalStorage<LocalStorageUser>('user');
    const id = user && user.id;

    const theme = me && me.colorScheme ? 1 : 0;

    useEffect((): void => {
        if (theme === 0) setColorScheme(false);
        if (theme === 1) setColorScheme(true);
    }, [theme]);

    const logout = async (): Promise<void> => {
        deleteFromStorage('apollo-cache-persist');
        deleteFromStorage('user');
    };

    const handleColorSchemeChange = async (): Promise<void> => {
        const colorTheme = colorScheme ? 0 : 1;
        await updateUser({
            variables: {
                id,
                colorScheme: colorTheme,
            },
        });
    };

    return (
        <div className={classes.container}>
            <Typography variant="h4" color="textSecondary" component="p">
                Menu
            </Typography>
            <List component="nav" className={classes.root} aria-label="Mobile Settings">
                <ListItem button component={Link} to="/account">
                    <ListItemText primary="Account" />
                </ListItem>
                <Divider light />
                <ListItem button component={Link} to="/friends">
                    <ListItemText primary="Friends" />
                </ListItem>
                <Divider />
                <ListItem button divider>
                    <ListItemText primary="Notifications" />
                </ListItem>
                <ListItem button>
                    <ListItemText primary="Change color scheme" />
                    <Switch
                        checked={colorScheme}
                        onChange={(): void => {
                            handleColorSchemeChange();
                        }}
                        value="color scheme"
                        inputProps={{ 'aria-label': 'secondary checkbox' }}
                    />
                </ListItem>
                <Divider light />
                <ListItem button>
                    <ListItemText primary="Logout" onClick={logout} />
                </ListItem>
            </List>
        </div>
    );
};
