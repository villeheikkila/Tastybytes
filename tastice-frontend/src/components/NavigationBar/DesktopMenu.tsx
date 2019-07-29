import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { themeSwitcher } from '../../utils';
import { THEME } from '../../queries';
import { useQuery } from '@apollo/react-hooks';

import { makeStyles, Switch, Menu, Badge, MenuItem, createStyles } from '@material-ui/core';
import { ExitToApp, BrightnessLow, BrightnessHigh, AccountCircle, PersonOutline } from '@material-ui/icons/';

const useStyles = makeStyles(() =>
    createStyles({
        badge: {
            marginRight: 15,
        },
    }),
);

interface DesktopMenuProps {
    anchorEl: Element | null | undefined;
    setAnchorEl: any;
    setToken: any;
}

export const DesktopMenu = ({ anchorEl, setAnchorEl, setToken }: DesktopMenuProps): JSX.Element => {
    const classes = useStyles();
    const [colorScheme, setColorScheme] = useState(false);
    const themeQuery = useQuery(THEME);
    const theme = themeQuery.data.theme ? 1 : 0;

    useEffect(() => {
        if (theme === 0) setColorScheme(false);
        if (theme === 1) setColorScheme(true);
    }, [theme]);

    const logout = (): void => {
        localStorage.clear();
        setToken(null);
    };

    return (
        <Menu
            anchorEl={anchorEl}
            anchorOrigin={{ vertical: 'top', horizontal: 'right' }}
            id="primary-search-account-menu"
            keepMounted
            transformOrigin={{ vertical: 'top', horizontal: 'right' }}
            open={Boolean(anchorEl)}
            onClose={() => setAnchorEl(null)}
        >
            <MenuItem>
                {colorScheme ? (
                    <Badge badgeContent={0} color="secondary" className={classes.badge}>
                        <BrightnessLow />
                    </Badge>
                ) : (
                    <Badge badgeContent={0} color="secondary" className={classes.badge}>
                        <BrightnessHigh />
                    </Badge>
                )}
                <Switch
                    checked={colorScheme}
                    onChange={(event: React.ChangeEvent<HTMLInputElement>) => {
                        themeSwitcher(event.target.checked);
                    }}
                    value="color scheme"
                    inputProps={{ 'aria-label': 'secondary checkbox' }}
                />
            </MenuItem>
            <MenuItem component={Link} to="/account" onClick={() => setAnchorEl(null)}>
                <Badge badgeContent={0} color="secondary" className={classes.badge}>
                    <AccountCircle />
                </Badge>
                Account
            </MenuItem>
            <MenuItem button component={Link} to="/friends">
                <Badge badgeContent={0} color="secondary" className={classes.badge}>
                    <PersonOutline />
                </Badge>
                Friends
            </MenuItem>
            <MenuItem onClick={logout}>
                <Badge badgeContent={0} color="secondary" className={classes.badge}>
                    <ExitToApp />
                </Badge>
                Logout
            </MenuItem>
        </Menu>
    );
};
