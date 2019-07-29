import React, { useState } from 'react';
import { ME, SEARCH_USERS, FRIENDREQUEST } from '../../queries';
import { useQuery } from '@apollo/react-hooks';
import { UserListItem } from './UserListItem';
import { FriendListItem } from './FriendListItem';
import { FriendRequestListItem } from './FriendRequestsListItem';
import { errorHandler } from '../../utils';
import { fade } from '@material-ui/core/styles';

import { createStyles, InputBase, Card, Theme, makeStyles, Divider, List, ListSubheader } from '@material-ui/core';
import SearchIcon from '@material-ui/icons/Search';

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
        search: {
            position: 'relative',
            borderRadius: theme.shape.borderRadius,
            backgroundColor: fade(theme.palette.common.white, 0.15),
            '&:hover': {
                backgroundColor: fade(theme.palette.common.white, 0.25),
            },
            margin: theme.spacing(1),
            width: 'auto',
        },
        searchIcon: {
            width: theme.spacing(7),
            height: '100%',
            position: 'absolute',
            pointerEvents: 'none',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
        },
        inputRoot: {
            color: 'inherit',
        },
        inputInput: {
            padding: theme.spacing(1, 1, 1, 7),
            transition: theme.transitions.create('width'),
            width: '100%',
            [theme.breakpoints.up('md')]: {
                width: 200,
            },
        },
    }),
);

export const FriendList = (id: any): JSX.Element | null => {
    const classes = useStyles();
    const me = useQuery(ME);
    const [search, setSearch] = useState('');

    const usersQuery = useQuery(SEARCH_USERS, {
        variables: { name: search },
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
                    {friends.map(
                        (user: SimpleUserObject): JSX.Element => (
                            <div key={user.id.toUpperCase()}>
                                <Divider light />
                                <FriendListItem key={user.id} user={user} userId={id} />
                                <Divider light />
                            </div>
                        ),
                    )}
                </List>
            )}
            {friendRequests.length !== 0 && (
                <>
                    <List
                        className={classes.list}
                        aria-labelledby="nested-list-subheader"
                        subheader={<ListSubheader component="div">Pending Friend Requests</ListSubheader>}
                    >
                        {friendRequests.map(
                            (request: FriendRequestObject): JSX.Element => (
                                <div key={request.id.toUpperCase()}>
                                    <Divider light />
                                    <FriendRequestListItem key={request.id} request={request} userId={id} />
                                    <Divider light />
                                </div>
                            ),
                        )}
                    </List>
                </>
            )}

            <List
                className={classes.list}
                aria-labelledby="nested-list-subheader"
                subheader={
                    <div className={classes.search}>
                        <div className={classes.searchIcon}>
                            <SearchIcon />
                        </div>
                        <InputBase
                            placeholder="Search Users"
                            classes={{
                                root: classes.inputRoot,
                                input: classes.inputInput,
                            }}
                            value={search}
                            onChange={({ target: { value } }): void => setSearch(value)}
                            inputProps={{ 'aria-label': 'Search' }}
                        />
                    </div>
                }
            >
                {users.map(
                    (user: SimpleUserObject): JSX.Element => (
                        <div key={user.id.toUpperCase()}>
                            <Divider light />
                            <UserListItem key={user.id} user={user} userId={id} />
                            <Divider light />
                        </div>
                    ),
                )}
            </List>
        </Card>
    );
};
