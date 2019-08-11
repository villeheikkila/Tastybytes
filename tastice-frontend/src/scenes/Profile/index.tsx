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
import React, { Fragment, useState } from 'react';
import { Link } from 'react-router-dom';
import { Waypoint } from 'react-waypoint';
import { CheckInCard } from '../../components/CheckInCard';
import { Divider } from '../../components/Divider';
import { SmartAvatar } from '../../components/SmartAvatar';
import { FILTER, USER } from '../../graphql';
import { SEARCH_USER_CHECKINS } from '../../graphql/checkin';
import { RatingChart } from './RatingChart';

const useStyles = makeStyles((theme: Theme) =>
    createStyles({
        paper: {
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
    const [ratingFilter, setRatingFilter] = useState();
    const { data: filterData, client } = useQuery(FILTER);

    const user = useQuery(USER, {
        variables: { id },
    });

    const { data, fetchMore } = useQuery(SEARCH_USER_CHECKINS, {
        variables: { id: id, filter: filterData.filter, first: 5 },
        onError: error => {
            client.writeData({
                data: {
                    notification: error.message,
                    variant: 'error',
                },
            });
        },
    });

    if (user.data.user === undefined || data.searchUserCheckins === undefined) {
        return null;
    }

    const loadMore = (): void => {
        fetchMore({
            variables: {
                skip: data.searchUserCheckins.length,
            },
            updateQuery: (prev: any, { fetchMoreResult }) => {
                if (!fetchMoreResult) return prev;
                return Object.assign({}, prev, {
                    searchUserCheckins: [...prev.searchUserCheckins, ...fetchMoreResult.searchUserCheckins],
                });
            },
        });
    };

    const userObject = {
        id: user.data.user[0].id,
        firstName: user.data.user[0].firstName,
        lastName: user.data.user[0].lastName,
        checkins: user.data.user[0].checkins,
        friends: user.data.user[0].friends,
        avatarId: user.data.user[0].avatarId,
        avatarColor: user.data.user[0].avatarColor,
    };

    const ratings = userObject.checkins
        .reduce(
            (count: number[], checkin: CheckInObject) => (
                (count[checkin.rating - 1] = ++count[checkin.rating - 1] || 1), count
            ),
            new Array(5).fill(0),
        )
        .map((count: number, index: number) => ({
            value: index + 1,
            count,
        }));

    const dividerText = userObject.checkins.length === 0 ? 'No Recent Activity' : 'Recent Activity';

    return (
        <div className={classes.root}>
            <Paper className={classes.paper}>
                <Typography variant="h4" component="h3" className={classes.textField}>
                    {userObject.firstName} {userObject.lastName}
                </Typography>
                <SmartAvatar
                    id={id}
                    size={200}
                    firstName={userObject.firstName}
                    lastName={userObject.lastName}
                    avatarId={userObject.avatarId}
                    avatarColor={userObject.avatarColor}
                    isClickable={false}
                />
                <Typography variant="h4" component="h3" className={classes.textField}>
                    Checkins in total: {userObject.checkins.length}
                </Typography>
            </Paper>

            <Paper className={classes.paper}>
                <RatingChart ratings={ratings} setRatingFilter={setRatingFilter} />
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

            {data.searchUserCheckins
                .filter((checkin: CheckInObject) => !ratingFilter || checkin.rating === ratingFilter)
                .map(
                    (checkin: CheckInObject, index: number): JSX.Element => (
                        <Fragment key={index}>
                            {data.searchUserCheckins.length - index <= 1 && <Waypoint onEnter={loadMore} />}
                            <CheckInCard key={checkin.id} checkin={checkin} showProduct={true} />
                        </Fragment>
                    ),
                )}
        </div>
    );
};
