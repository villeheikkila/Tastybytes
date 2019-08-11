import {
    createStyles,
    ExpansionPanel,
    ExpansionPanelDetails,
    ExpansionPanelSummary,
    List,
    ListItem,
    ListItemAvatar,
    ListItemText,
    makeStyles,
    Theme,
    Typography,
} from '@material-ui/core';
import ExpandMoreIcon from '@material-ui/icons/ExpandMore';
import React from 'react';
import { Link } from 'react-router-dom';
import { SmartAvatar } from '../../components/SmartAvatar';

const useStyles = makeStyles((theme: Theme) =>
    createStyles({
        friends: {
            maxWidth: 700,
            margin: `${theme.spacing(1)}px auto`,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            alignContent: 'center',
        },
        smallAvatar: {
            margin: 10,
        },
        textField: {
            marginTop: 10,
        },
        button: {
            marginTop: 30,
        },
        root: {
            alignItems: 'center',
        },
        heading: {},
        panel: {
            width: '100%',
        },
    }),
);

export const ExpansionFriendList = ({ friends }: any): JSX.Element | null => {
    console.log('TCL: friends', friends);
    const classes = useStyles();

    return (
        <div className={classes.friends}>
            <ExpansionPanel className={classes.panel}>
                <ExpansionPanelSummary expandIcon={<ExpandMoreIcon />} aria-controls="panel1a-content">
                    <Typography variant="h6" component="h6" className={classes.heading}>
                        Friends
                    </Typography>
                </ExpansionPanelSummary>
                <ExpansionPanelDetails>
                    <List>
                        {friends.map((user: User) => (
                            <ListItem
                                button
                                alignItems="flex-start"
                                component={Link}
                                to={`/user/${user.id}`}
                                key={user.id}
                            >
                                <ListItemAvatar>
                                    <SmartAvatar
                                        firstName={user.firstName}
                                        lastName={user.lastName}
                                        id={user.id}
                                        avatarId={user.avatarId}
                                    />
                                </ListItemAvatar>
                                <ListItemText primary={`${user.firstName} ${user.lastName}`} />
                            </ListItem>
                        ))}
                    </List>
                </ExpansionPanelDetails>
            </ExpansionPanel>
        </div>
    );
};
