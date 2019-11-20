import { useQuery } from '@apollo/react-hooks';
import { createStyles, makeStyles, Paper, Theme, Typography } from '@material-ui/core';
import React, { Fragment, useState } from 'react';
import { Waypoint } from 'react-waypoint';
import { CheckInCard } from '../../components/CheckInCard';
import { Divider } from '../../components/Divider';
import { Loading } from '../../components/Loading';
import { SmartAvatar } from '../../components/SmartAvatar';
import { FILTER, USER } from '../../graphql';
import { SEARCH_USER_CHECKINS } from '../../graphql/checkin';
import { ExpansionFriendList } from './ExpansionFriendList';
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

export const Profile = ({ id }: IdObject): JSX.Element => {
    const classes = useStyles({});
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

    if (!user.data || !user.data.user || !data.searchUserCheckins) {
        return <Loading />;
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

            <ExpansionFriendList friends={userObject.friends} />

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
