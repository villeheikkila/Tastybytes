import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { themeSwitcher } from '../../utils';
import { THEME } from '../../queries';
import { useQuery } from '@apollo/react-hooks';

import {
    createStyles,
    Theme,
    makeStyles,
    ListItemText,
    Divider,
    Typography,
    Switch,
    List,
    ListItem,
} from '@material-ui/core';

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

export const MobileMenu = ({ setToken }: Token): JSX.Element => {
    const classes = useStyles();
    const [colorScheme, setColorScheme] = useState(false);
    const themeQuery = useQuery(THEME);
    const theme = themeQuery.data.theme ? 1 : 0;

    useEffect((): void => {
        if (theme === 0) setColorScheme(false);
        if (theme === 1) setColorScheme(true);
    }, [theme]);

    const logout = (): void => {
        localStorage.clear();
        setToken(null);
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
                        onChange={(event: React.ChangeEvent<HTMLInputElement>): void => {
                            themeSwitcher(event.target.checked);
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
