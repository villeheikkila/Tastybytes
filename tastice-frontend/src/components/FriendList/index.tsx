import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { ME, FILTER, SEARCH_USERS } from '../../queries';
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

    if (users.data.searchUsers === undefined) {
        return null;
    }

    const me = meQuery.data.me;

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
