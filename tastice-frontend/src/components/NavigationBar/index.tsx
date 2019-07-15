import React, { useState } from "react";
import { Link } from "react-router-dom";
import { INavbar } from "../../types";
import { themeSwitcher } from "../../utils";

import {
  fade,
  makeStyles,
  Theme,
  createStyles
} from "@material-ui/core/styles";
import AppBar from "@material-ui/core/AppBar";
import Toolbar from "@material-ui/core/Toolbar";
import IconButton from "@material-ui/core/IconButton";
import ButtonBase from "@material-ui/core/ButtonBase";
import "typeface-leckerli-one";
import Typography from "@material-ui/core/Typography";
import InputBase from "@material-ui/core/InputBase";
import ExitToApp from "@material-ui/icons/ExitToApp";
import BrightnessHigh from "@material-ui/icons/BrightnessHigh";
import BrightnessLow from "@material-ui/icons/BrightnessLow";
import Badge from "@material-ui/core/Badge";
import MenuItem from "@material-ui/core/MenuItem";
import Menu from "@material-ui/core/Menu";
import SearchIcon from "@material-ui/icons/Search";
import AccountCircle from "@material-ui/icons/AccountCircle";
import NotificationsIcon from "@material-ui/icons/Notifications";
import MoreIcon from "@material-ui/icons/MoreVert";
import Switch from "@material-ui/core/Switch";
import history from "../../utils/history";

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    grow: {
      flexGrow: 1
    },
    title: {
      display: "none",
      [theme.breakpoints.up("sm")]: {
        display: "block"
      }
    },
    search: {
      position: "relative",
      borderRadius: theme.shape.borderRadius,
      backgroundColor: fade(theme.palette.common.white, 0.15),
      "&:hover": {
        backgroundColor: fade(theme.palette.common.white, 0.25)
      },
      marginRight: theme.spacing(2),
      marginLeft: 0,
      width: "100%",
      [theme.breakpoints.up("sm")]: {
        marginLeft: theme.spacing(3),
        width: "auto"
      }
    },
    searchIcon: {
      width: theme.spacing(7),
      height: "100%",
      position: "absolute",
      pointerEvents: "none",
      display: "flex",
      alignItems: "center",
      justifyContent: "center"
    },
    inputRoot: {
      color: "inherit"
    },
    inputInput: {
      padding: theme.spacing(1, 1, 1, 7),
      transition: theme.transitions.create("width"),
      width: "100%",
      [theme.breakpoints.up("md")]: {
        width: 200
      }
    },
    sectionDesktop: {
      display: "none",
      [theme.breakpoints.up("md")]: {
        display: "flex"
      }
    },
    sectionMobile: {
      display: "flex",
      [theme.breakpoints.up("md")]: {
        display: "none"
      }
    },
    root: {
      display: "flex"
    },
    textLink: {
      paddingRight: 15,
      fontFamily: "Leckerli One"
    },
    logo: {
      fontFamily: "Leckerli One"
    },
    badge: {
      marginRight: 15
    }
  })
);

export const NavigationBar: React.FC<INavbar> = ({ setToken }) => {
  const classes = useStyles();
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
  const [colorScheme, setColorScheme] = useState(false);

  const logout = () => {
    localStorage.clear();
    setToken(null);
  };

  const handleColorSchemeChange = (
    event: React.ChangeEvent<HTMLInputElement>
  ) => {
    themeSwitcher(event.target.checked);
    setColorScheme(event.target.checked);
  };

  const isMenuOpen = Boolean(anchorEl);

  const handleProfileMenuOpen = (event: React.MouseEvent<HTMLElement>) =>
    setAnchorEl(event.currentTarget);

  const handleMenuClose = () => {
    setAnchorEl(null);
  };

  return (
    <div className={classes.grow}>
      <AppBar position="fixed" color="default">
        <Toolbar>
          <ButtonBase
            focusRipple
            className={classes.textLink}
            key="Tastice"
            component={Link}
            to="/"
          >
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
              to="/myprofile"
            >
              <Typography variant="h6" noWrap>
                My Profile
              </Typography>
            </ButtonBase>
          </div>

          <div className={classes.search}>
            <div className={classes.searchIcon}>
              <SearchIcon />
            </div>
            <InputBase
              placeholder="Search…"
              classes={{
                root: classes.inputRoot,
                input: classes.inputInput
              }}
              inputProps={{ "aria-label": "Search" }}
            />
          </div>

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
              onClick={() => history.push("/menu")}
              color="inherit"
            >
              <MoreIcon />
            </IconButton>
          </div>
        </Toolbar>
      </AppBar>

      <Menu
        anchorEl={anchorEl}
        anchorOrigin={{ vertical: "top", horizontal: "right" }}
        id="primary-search-account-menu"
        keepMounted
        transformOrigin={{ vertical: "top", horizontal: "right" }}
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
            inputProps={{ "aria-label": "secondary checkbox" }}
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
