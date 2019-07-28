import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { Token } from '../../types';
import { themeSwitcher, filterChanger } from '../../utils';
import useReactRouter from 'use-react-router';
import MoreIcon from '@material-ui/icons/MoreVert';
import NotificationsIcon from '@material-ui/icons/Notifications';
import { fade } from '@material-ui/core/styles';
import 'typeface-leckerli-one';
import { SearchInputBase } from './SearchInputBase';

import {
    makeStyles,
    AppBar,
    Toolbar,
    ButtonBase,
    InputBase,
    Switch,
    Menu,
    Badge,
    MenuItem,
    IconButton,
    Typography,
    Theme,
    createStyles,
} from '@material-ui/core';

import { ExitToApp, BrightnessLow, BrightnessHigh, AccountCircle } from '@material-ui/icons/';

const useStyles = makeStyles((theme: Theme) =>
    createStyles({
        grow: {
            flexGrow: 1,
        },
        title: {
            display: 'none',
            [theme.breakpoints.up('sm')]: {
                display: 'block',
            },
        },
        search: {
            position: 'relative',
            borderRadius: theme.shape.borderRadius,
            backgroundColor: fade(theme.palette.common.white, 0.15),
            '&:hover': {
                backgroundColor: fade(theme.palette.common.white, 0.25),
            },
            marginRight: theme.spacing(2),
            marginLeft: 0,
            width: '100%',
            [theme.breakpoints.up('sm')]: {
                marginLeft: theme.spacing(3),
                width: 'auto',
            },
        },
        sectionDesktop: {
            display: 'none',
            [theme.breakpoints.up('md')]: {
                display: 'flex',
            },
        },
        sectionMobile: {
            display: 'flex',
            [theme.breakpoints.up('md')]: {
                display: 'none',
            },
        },
        root: {
            display: 'flex',
        },
        textLink: {
            paddingRight: 15,
            fontFamily: 'Leckerli One',
        },
        logo: {
            fontFamily: 'Leckerli One',
        },
        badge: {
            marginRight: 15,
        },
    }),
);

export const NavigationBar: React.FC<Token> = ({ setToken }) => {
    const classes = useStyles();
    const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
    const [filter, setFilter] = useState('');
    const [colorScheme, setColorScheme] = useState(false);
    const { history, location } = useReactRouter();

    const logout = () => {
        localStorage.clear();
        setToken(null);
    };

    filterChanger(filter);

    const searchLocations = ['activity', 'discover', 'user'];

    const showSearch = searchLocations.includes(location.pathname.split('/')[1]);

    const handleColorSchemeChange = (event: React.ChangeEvent<HTMLInputElement>) => {
        themeSwitcher(event.target.checked);
        setColorScheme(event.target.checked);
    };

    const isMenuOpen = Boolean(anchorEl);

    const handleProfileMenuOpen = (event: React.MouseEvent<HTMLElement>) => setAnchorEl(event.currentTarget);

    const handleMenuClose = () => {
        setAnchorEl(null);
    };

    return (
        <div className={classes.grow}>
            <AppBar position="fixed" color="default">
                <Toolbar>
                    <ButtonBase focusRipple className={classes.textLink} key="Tastice" component={Link} to="/">
                        <Typography variant="h4" noWrap className={classes.logo}>
                            Tastice
                        </Typography>
                    </ButtonBase>
                    <div className={classes.sectionDesktop}>
                        <ButtonBase
                            focusRipple
                            className={classes.textLink}
                            key="Activity"
                            component={Link}
                            to="/activity"
                        >
                            <Typography variant="h6" noWrap>
                                Activity
                            </Typography>
                        </ButtonBase>

                        <ButtonBase
                            focusRipple
                            className={classes.textLink}
                            key="Discover"
                            component={Link}
                            to="/discover"
                        >
                            <Typography variant="h6" noWrap>
                                Discover
                            </Typography>
                        </ButtonBase>

                        <ButtonBase
                            focusRipple
                            className={classes.textLink}
                            key="My Profile"
                            component={Link}
                            to="/profile"
                        >
                            <Typography variant="h6" noWrap>
                                My Profile
                            </Typography>
                        </ButtonBase>
                    </div>

                    {showSearch && <SearchInputBase search={filter} setSearch={setFilter} placeholder={'Search...'} />}

                    <div className={classes.grow} />
                    <div className={classes.sectionDesktop}>
                        <IconButton aria-label="Show new notifications" color="inherit">
                            <Badge badgeContent={0} color="secondary">
                                <NotificationsIcon />
                            </Badge>
                        </IconButton>
                        <IconButton
                            edge="end"
                            aria-label="Account of current user"
                            aria-controls="primary-search-account-menu"
                            aria-haspopup="true"
                            onClick={handleProfileMenuOpen}
                            color="inherit"
                        >
                            <AccountCircle />
                        </IconButton>
                    </div>

                    <div className={classes.sectionMobile}>
                        <IconButton
                            aria-label="Show more"
                            aria-controls="Mobile Menu"
                            aria-haspopup="true"
                            onClick={() => history.push('/menu')}
                            color="inherit"
                        >
                            <MoreIcon />
                        </IconButton>
                    </div>
                </Toolbar>
            </AppBar>

            <Menu
                anchorEl={anchorEl}
                anchorOrigin={{ vertical: 'top', horizontal: 'right' }}
                id="primary-search-account-menu"
                keepMounted
                transformOrigin={{ vertical: 'top', horizontal: 'right' }}
                open={isMenuOpen}
                onClose={handleMenuClose}
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
                        onChange={handleColorSchemeChange}
                        value="color scheme"
                        inputProps={{ 'aria-label': 'secondary checkbox' }}
                    />
                </MenuItem>
                <MenuItem component={Link} to="/account" onClick={handleMenuClose}>
                    <Badge badgeContent={0} color="secondary" className={classes.badge}>
                        <AccountCircle />
                    </Badge>
                    Account
                </MenuItem>
                <MenuItem onClick={logout}>
                    <Badge badgeContent={0} color="secondary" className={classes.badge}>
                        <ExitToApp />
                    </Badge>
                    Logout
                </MenuItem>
            </Menu>
        </div>
    );
};
