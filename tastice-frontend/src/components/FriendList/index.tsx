import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { ME, FILTER, SEARCH_USERS, FRIENDREQUEST } from '../../queries';
import { useQuery, useMutation } from '@apollo/react-hooks';
import { FriendListItem } from './FriendListItem';
import { Friends } from './Friends';
import { FriendRequestListItem } from './FriendRequestsList';
import { errorHandler } from '../../utils';

import { createStyles, Theme, makeStyles, Divider, List } from '@material-ui/core';

const useStyles = makeStyles((theme: Theme) =>
    createStyles({
        root: {
            width: '100%',
            maxWidth: 360,
            backgroundColor: theme.palette.background.paper,
        },
        inline: {
            display: 'inline',
        },
    }),
);

export const FriendList = (id: any) => {
    console.log('id: ', id);
    const classes = useStyles();
    const me = useQuery(ME);
    console.log('me: ', me);
    const filter = useQuery(FILTER);
    const users = useQuery(SEARCH_USERS, {
        variables: { name: filter.data.filter },
        onError: errorHandler,
    });

    const friendRequests = useQuery(FRIENDREQUEST, {
        variables: { id: id.id },
    });

    console.log('friendRequests: ', friendRequests);

    if (users.data.searchUsers === undefined || me.data.me.friends === undefined) {
        return null;
    }

    return (
        <div>
            <h3>Friends</h3>
            <List className={classes.root}>
                {me.data.me.friends.map((user: any) => (
                    <>
                        <Friends key={user.id} user={user} userId={id} />
                        <Divider light />
                    </>
                ))}
            </List>

            <h3>Pending Friend Requests</h3>
            <List className={classes.root}>
                {friendRequests.data.friendRequest.map((request: any) => (
                    <>
                        <FriendRequestListItem key={request.id} request={request} userId={id} />
                        <Divider light />
                    </>
                ))}
            </List>
            <h3>All users</h3>
            <List className={classes.root}>
                {users.data.searchUsers.map((user: any) => (
                    <>
                        <FriendListItem key={user.id} user={user} userId={id} />
                        <Divider light />
                    </>
                ))}
            </List>
        </div>
    );
};
