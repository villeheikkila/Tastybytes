import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { ME, FILTER, SEARCH_USERS, FRIENDREQUEST } from '../../queries';
import { useQuery, useMutation } from '@apollo/react-hooks';
import { FriendListItem } from './FriendListItem';
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

export const FriendList = () => {
    const classes = useStyles();
    const filter = useQuery(FILTER);
    const meQuery = useQuery(ME);
    const users = useQuery(SEARCH_USERS, {
        variables: { name: filter.data.filter },
        onError: errorHandler,
    });

    const me = meQuery.data.me;
    console.log('me: ', me);

    const friendRequests = useQuery(FRIENDREQUEST, {
        variables: { id: 'cjyjclp0w01va0741vqntjdu1' },
    });

    console.log('friendRequests: ', friendRequests);

    if (users.data.searchUsers === undefined) {
        return null;
    }

    return (
        <List className={classes.root}>
            {users.data.searchUsers.map((user: any) => (
                <>
                    <FriendListItem key={user.id} user={user} me={me} />
                    <Divider light />
                </>
            ))}
        </List>
    );
};
