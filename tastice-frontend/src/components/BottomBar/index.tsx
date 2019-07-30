import { BottomNavigation, BottomNavigationAction, makeStyles } from '@material-ui/core';
import { Explore, Face } from '@material-ui/icons/';
import ViewListIcon from '@material-ui/icons/ViewList';
import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import useReactRouter from 'use-react-router';

const useStyles = makeStyles({
    root: {
        width: '100%',
        position: 'fixed',
        bottom: 0,
    },
});

export const BottomBar = (): JSX.Element => {
    const classes = useStyles();
    const [highlight, setHighlight] = useState(3);
    const { location } = useReactRouter();

    const locations: string[] = ['activity', 'discover', 'user'];
    const currentLocation = locations.indexOf(location.pathname.split('/')[1]);

    if (currentLocation !== highlight) {
        setHighlight(currentLocation);
    }

    return (
        <BottomNavigation
            value={highlight}
            onChange={(event, newHighlight): void => {
                setHighlight(newHighlight);
            }}
            showLabels
            className={classes.root}
        >
            <BottomNavigationAction label="Activity" icon={<ViewListIcon />} component={Link} to="/activity" />
            <BottomNavigationAction label="Discover" icon={<Explore />} component={Link} to="/discover" />
            <BottomNavigationAction label="Profile" icon={<Face />} component={Link} to="/profile" />
        </BottomNavigation>
    );
};
