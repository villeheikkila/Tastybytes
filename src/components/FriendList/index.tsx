import { useQuery } from '@apollo/react-hooks';
import { Card, createStyles, Divider, InputBase, List, ListSubheader, makeStyles, Theme } from '@material-ui/core';
import { fade } from '@material-ui/core/styles';
import SearchIcon from '@material-ui/icons/Search';
import React, { useState } from 'react';
import { Loading } from '../../components/Loading';
import { FRIENDREQUEST, ME, SEARCH_USERS } from '../../graphql';
import { FriendListItem } from './FriendListItem';
import { FriendRequestListItem } from './FriendRequestsListItem';
import { UserListItem } from './UserListItem';

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

export const FriendList = (): JSX.Element => {
    const classes = useStyles({});
    const [filter, setFilter] = useState('');

    const { loading: meLoading, data, client } = useQuery(ME);
    const id = data && data.me.id;

    const { loading: userLoading, data: userData } = useQuery(SEARCH_USERS, {
        variables: { filter },
        onError: error => {
            client.writeData({
                data: {
                    notification: error.message,
                    variant: 'error',
                },
            });
        },
    });

    const { loading: friendRequestLoading, data: friendRequestData } = useQuery(FRIENDREQUEST, {
        variables: { id },
    });

    if (meLoading || userLoading || friendRequestLoading) return <Loading />;

    const { me } = data;
    const { searchUsers } = userData;
    const { friendRequest } = friendRequestData;

    const friends = me.friends;
    const friendRequests = friendRequest || [];

    const friendRequestIds = friendRequests.map(
        (friendRequestItem: FriendRequestObject) => friendRequestItem.sender[0].id,
    );

    const friendIds = friends.map((friendItem: User) => friendItem.id);

    const users = searchUsers.filter(
        (userItem: User) =>
            userItem.id !== id && !friendRequestIds.includes(userItem.id) && !friendIds.includes(userItem.id),
    );

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
                        (user: User): JSX.Element => (
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
                            value={filter}
                            onChange={({ target: { value } }): void => setFilter(value)}
                            inputProps={{ 'aria-label': 'Search' }}
                        />
                    </div>
                }
            >
                {users.map(
                    (user: User): JSX.Element => (
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
