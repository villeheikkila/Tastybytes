import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { ME, FILTER, SEARCH_USERS, FRIENDREQUEST } from '../../queries';
import { useQuery, useMutation } from '@apollo/react-hooks';
import { UserListItem } from './UserListItem';
import { FriendListItem } from './FriendListItem';
import { FriendRequestListItem } from './FriendRequestsListItem';
import { errorHandler } from '../../utils';

import { createStyles, Theme, makeStyles, Divider, List, Typography, ListSubheader } from '@material-ui/core';

const useStyles = makeStyles((theme: Theme) =>
    createStyles({
        list: {
            width: '100%',
            maxWidth: 360,
            backgroundColor: theme.palette.background.paper,
        },
    }),
);

export const FriendList = (id: any) => {
    const classes = useStyles();
    const me = useQuery(ME);
    const filter = useQuery(FILTER);

    const usersQuery = useQuery(SEARCH_USERS, {
        variables: { name: filter.data.filter },
        onError: errorHandler,
    });

    const friendRequest = useQuery(FRIENDREQUEST, {
        variables: { id: id.id },
    });

    if (usersQuery.data.searchUsers === undefined || me.data.me === undefined) {
        return null;
    }

    const friends = me.data.me.friends;
    const friendRequests = friendRequest.data.friendRequest;
    const users = usersQuery.data.searchUsers;

    return (
        <div>
            {friends.length !== 0 && (
                <List
                    className={classes.list}
                    aria-labelledby="nested-list-subheader"
                    subheader={
                        <ListSubheader component="div" id="nested-list-subheader">
                            Friends
                        </ListSubheader>
                    }
                >
                    {friends.map((user: any) => (
                        <>
                            <Divider light />
                            <FriendListItem key={user.id} user={user} userId={id} />
                            <Divider light />
                        </>
                    ))}
                </List>
            )}
            {friendRequests.length !== 0 && (
                <>
                    <List
                        className={classes.list}
                        component="nav"
                        aria-labelledby="nested-list-subheader"
                        subheader={<ListSubheader component="div">Pending Friend Requests</ListSubheader>}
                    >
                        {friendRequests.map((request: any) => (
                            <>
                                <Divider light />
                                <FriendRequestListItem key={request.id} request={request} userId={id} />
                                <Divider light />
                            </>
                        ))}
                    </List>
                </>
            )}

            <List
                className={classes.list}
                component="nav"
                aria-labelledby="nested-list-subheader"
                subheader={<ListSubheader component="div">All Users</ListSubheader>}
            >
                {users.map((user: any) => (
                    <>
                        <Divider light />
                        <UserListItem key={user.id} user={user} userId={id} />
                        <Divider light />
                    </>
                ))}
            </List>
        </div>
    );
};
