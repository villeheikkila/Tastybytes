import React, { useState } from 'react';
import { makeStyles } from '@material-ui/core/styles';
import BottomNavigation from '@material-ui/core/BottomNavigation';
import BottomNavigationAction from '@material-ui/core/BottomNavigationAction';
import Explore from '@material-ui/icons/Explore';
import Face from '@material-ui/icons/Face';
import ViewListIcon from '@material-ui/icons/ViewList';
import { Link } from "react-router-dom";

const useStyles = makeStyles({
    root: {
        width: "100%",
        position: "fixed",
        bottom: 0,
    },
});

export const BottomBar = () => {
    const classes = useStyles();
    const [value, setValue] = useState(0);

    return (
        <BottomNavigation
            value={value}
            onChange={(event, newValue) => {
                setValue(newValue);
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