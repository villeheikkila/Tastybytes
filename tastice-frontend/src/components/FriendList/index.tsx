import React from 'react';
import { ME, FILTER, SEARCH_USERS, FRIENDREQUEST } from '../../queries';
import { useQuery } from '@apollo/react-hooks';
import { UserListItem } from './UserListItem';
import { FriendListItem } from './FriendListItem';
import { FriendRequestListItem } from './FriendRequestsListItem';
import { errorHandler } from '../../utils';

import { createStyles, Card, Theme, makeStyles, Divider, List, ListSubheader } from '@material-ui/core';

const useStyles = makeStyles((theme: Theme) =>
    createStyles({
        root: {
            flexGrow: 1,
            overflow: 'hidden',
            maxWidth: 700,
            margin: `${theme.spacing(1)}px auto`,
            alignContent: 'center',
            justifyContent: 'center',
        },
        list: {
            width: '100%',
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
        <Card className={classes.root}>
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
                        <div key={user.id.toUpperCase()}>
                            <Divider light />
                            <FriendListItem key={user.id} user={user} userId={id} />
                            <Divider light />
                        </div>
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
                            <div key={request.id.toUpperCase()}>
                                <Divider light />
                                <FriendRequestListItem key={request.id} request={request} userId={id} />
                                <Divider light />
                            </div>
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
                    <div key={user.id.toUpperCase()}>
                        <Divider light />
                        <UserListItem key={user.id} user={user} userId={id} />
                        <Divider light />
                    </div>
                ))}
            </List>
        </Card>
    );
};
