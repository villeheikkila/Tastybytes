import React, { useState } from 'react';
import { makeStyles } from '@material-ui/core/styles';
import BottomNavigation from '@material-ui/core/BottomNavigation';
import BottomNavigationAction from '@material-ui/core/BottomNavigationAction';
import Explore from '@material-ui/icons/Explore';
import Face from '@material-ui/icons/Face';
import ViewListIcon from '@material-ui/icons/ViewList';
import { Link } from "react-router-dom";
import useReactRouter from 'use-react-router';

const useStyles = makeStyles({
    root: {
        width: "100%",
        position: "fixed",
        bottom: 0,
    },
});

export const BottomBar = () => {
    const classes = useStyles();
    const [highlight, setHighlight] = useState(3);
    const { location } = useReactRouter();

    if (location.pathname === "/activity" && highlight !== 0) { setHighlight(0) }
    else if (location.pathname === "/discover" && highlight !== 1) { setHighlight(1) }
    else if (location.pathname === "/myprofile" && highlight !== 2) { setHighlight(2) }
    else if (location.pathname !== "/discover" && location.pathname !== "/activity" && location.pathname !== "/myprofile" && highlight !== 3) {
        setHighlight(3)
    }

    return (
        <BottomNavigation
            value={highlight}

            onChange={(event, newHighlight) => {
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
}