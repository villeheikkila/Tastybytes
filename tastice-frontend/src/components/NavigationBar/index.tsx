import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { themeSwitcher, filterChanger } from '../../utils';
import useReactRouter from 'use-react-router';
import MoreIcon from '@material-ui/icons/MoreVert';
import NotificationsIcon from '@material-ui/icons/Notifications';
import { fade } from '@material-ui/core/styles';
import 'typeface-leckerli-one';
import { SearchInputBase } from './SearchInputBase';
import { DesktopMenu } from './DesktopMenu';

import {
    makeStyles,
    AppBar,
    Toolbar,
    ButtonBase,
    Badge,
    IconButton,
    Typography,
    Theme,
    createStyles,
} from '@material-ui/core';

import { AccountCircle } from '@material-ui/icons/';

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
    }),
);

export const NavigationBar: React.FC<Token> = ({ setToken }) => {
    const classes = useStyles();
    const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
    const [filter, setFilter] = useState('');
    const { location } = useReactRouter();

    filterChanger(filter);

    const searchLocations = ['activity', 'discover', 'user'];

    const showSearch = searchLocations.includes(location.pathname.split('/')[1]);

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
                            onClick={(event: React.MouseEvent<HTMLElement>) => setAnchorEl(event.currentTarget)}
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
                            component={Link}
                            to="/menu"
                            color="inherit"
                        >
                            <MoreIcon />
                        </IconButton>
                    </div>
                </Toolbar>
            </AppBar>
            <DesktopMenu anchorEl={anchorEl} setAnchorEl={setAnchorEl} setToken={setToken} />
        </div>
    );
};
