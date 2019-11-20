import { useMutation, useQuery } from '@apollo/react-hooks';
import { Badge, createStyles, makeStyles, Menu, MenuItem, Switch } from '@material-ui/core';
import { AccountCircle, BrightnessHigh, BrightnessLow, ExitToApp, PersonOutline, Settings } from '@material-ui/icons/';
import { deleteFromStorage } from '@rehooks/local-storage';
import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { Loading } from '../../components/Loading';
import { ME, UPDATE_USER } from '../../graphql';

const useStyles = makeStyles(() =>
    createStyles({
        badge: {
            marginRight: 15,
        },
    }),
);

interface DesktopMenuProps {
    anchorEl: Element | null | undefined;
    setAnchorEl: React.Dispatch<React.SetStateAction<HTMLElement | null>>;
}

export const DesktopMenu = ({ anchorEl, setAnchorEl }: DesktopMenuProps): JSX.Element => {
    const classes = useStyles({});
    const [colorScheme, setColorScheme] = useState(false);
    const { data, client } = useQuery(ME);

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

    const theme = data && data.me && data.me.colorScheme ? 1 : 0;
    const admin = (data && data.me && data.me.admin) || false;

    useEffect((): void => {
        if (theme === 0) setColorScheme(false);
        if (theme === 1) setColorScheme(true);
    }, [theme]);

    if (data === undefined) {
        return <Loading />;
    }
    const { me } = data;

    const logout = async (): Promise<void> => {
        deleteFromStorage('apollo-cache-persist');
        deleteFromStorage('user');
    };

    const handleColorSchemeChange = async (): Promise<void> => {
        const colorTheme = colorScheme ? 0 : 1;
        await updateUser({
            variables: {
                id: me.id,
                colorScheme: colorTheme,
            },
        });
    };

    return (
        <Menu
            anchorEl={anchorEl}
            anchorOrigin={{ vertical: 'top', horizontal: 'right' }}
            id="primary-search-account-menu"
            keepMounted
            transformOrigin={{ vertical: 'top', horizontal: 'right' }}
            open={Boolean(anchorEl)}
            onClose={(): void => setAnchorEl(null)}
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
                    onChange={(): Promise<void> => handleColorSchemeChange()}
                    value="color scheme"
                    inputProps={{ 'aria-label': 'secondary checkbox' }}
                />
            </MenuItem>
            <MenuItem component={Link} to="/account" onClick={(): void => setAnchorEl(null)}>
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
            {admin && (
                <MenuItem button component={Link} to="/dashboard">
                    <Badge badgeContent={0} color="secondary" className={classes.badge}>
                        <Settings />
                    </Badge>
                    Admin dashboard
                </MenuItem>
            )}
            <MenuItem onClick={logout}>
                <Badge badgeContent={0} color="secondary" className={classes.badge}>
                    <ExitToApp />
                </Badge>
                Logout
            </MenuItem>
        </Menu>
    );
};
