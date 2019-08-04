import { useQuery } from '@apollo/react-hooks';
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
    Paper,
    Theme,
    Typography,
} from '@material-ui/core';
import ExpandMoreIcon from '@material-ui/icons/ExpandMore';
import React from 'react';
import { Link } from 'react-router-dom';
import { CheckInCard } from '../../components/CheckInCard';
import { Divider } from '../../components/Divider';
import { SmartAvatar } from '../../components/SmartAvatar';
import { USER } from '../../graphql';

const useStyles = makeStyles((theme: Theme) =>
    createStyles({
        paper: {
            marginTop: 30,
            maxWidth: 700,
            padding: theme.spacing(1, 1),
            margin: `${theme.spacing(1)}px auto`,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            alignContent: 'center',
        },
        friends: {
            maxWidth: 700,
            margin: `${theme.spacing(1)}px auto`,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            alignContent: 'center',
        },
        avatar: {
            marginLeft: 30,
            marginRight: 30,
            marginTop: 15,
            marginBottom: 15,
            width: 150,
            height: 150,
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

export const Profile = ({ id }: IdObject): JSX.Element | null => {
    const classes = useStyles();
    const user = useQuery(USER, {
        variables: { id },
    });

    if (user.data.user === undefined) {
        return null;
    }

    const userObject = {
        firstName: user.data.user[0].firstName,
        lastName: user.data.user[0].lastName,
        checkins: user.data.user[0].checkins,
        friends: user.data.user[0].friends,
        avatarId: user.data.user[0].avatarId,
    };

    const dividerText = userObject.checkins.length === 0 ? 'No Recent Activity' : 'Recent Activity';

    return (
        <div className={classes.root}>
            <Paper className={classes.paper}>
                <Typography variant="h4" component="h3" className={classes.textField}>
                    {userObject.firstName} {userObject.lastName}
                </Typography>
                <SmartAvatar
                    id={id}
                    size={150}
                    firstName={userObject.firstName}
                    lastName={userObject.lastName}
                    avatarId={userObject.avatarId}
                />
                <Typography variant="h4" component="h3" className={classes.textField}>
                    Checkins in total: {userObject.checkins.length}
                </Typography>
            </Paper>

            <div className={classes.friends}>
                <ExpansionPanel className={classes.panel}>
                    <ExpansionPanelSummary expandIcon={<ExpandMoreIcon />} aria-controls="panel1a-content">
                        <Typography variant="h6" component="h6" className={classes.heading}>
                            Friends
                        </Typography>
                    </ExpansionPanelSummary>
                    <ExpansionPanelDetails>
                        <List>
                            {userObject.friends.map((user: User) => (
                                <ListItem
                                    button
                                    alignItems="flex-start"
                                    component={Link}
                                    to={`/user/${user.id}`}
                                    key={id}
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
                            <ListItem button alignItems="flex-start" key={id}>
                                <Typography component="p" className={classes.heading}>
                                    Send a friend request!
                                </Typography>
                            </ListItem>
                        </List>
                    </ExpansionPanelDetails>
                </ExpansionPanel>
            </div>

            <Divider text={dividerText} />

            {userObject.checkins.map(
                (checkin: CheckInObject): JSX.Element => (
                    <CheckInCard key={checkin.id} checkin={checkin} showProduct={true} />
                ),
            )}
        </div>
    );
};
