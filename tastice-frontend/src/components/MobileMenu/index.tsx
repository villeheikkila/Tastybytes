import React, { useState } from "react";
import { Link } from "react-router-dom";
import { themeSwitcher } from "../../utils";
import { Token } from "../../types";

import {
  createStyles,
  Theme,
  makeStyles,
  ListItemText,
  Divider,
  Typography,
  Switch,
  List,
  ListItem
} from "@material-ui/core";

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    container: {
      marginTop: 15
    },
    root: {
      marginTop: 15,
      width: "100%",
      backgroundColor: theme.palette.background.paper
    }
  })
);

export const MobileMenu: React.FC<Token> = ({ setToken }) => {
  const classes = useStyles();
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

  return (
    <div className={classes.container}>
      <Typography variant="h4" color="textSecondary" component="p">
        Menu
      </Typography>
      <List
        component="nav"
        className={classes.root}
        aria-label="Mobile Settings"
      >
        <ListItem button component={Link} to="/account">
          <ListItemText primary="Account" />
        </ListItem>
        <Divider />
        <ListItem button divider>
          <ListItemText primary="Notifications" />
        </ListItem>
        <ListItem button>
          <ListItemText primary="Change color scheme" />
          <Switch
            checked={colorScheme}
            onChange={handleColorSchemeChange}
            value="color scheme"
            inputProps={{ "aria-label": "secondary checkbox" }}
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
