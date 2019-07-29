import React from 'react';
import { useMutation } from '@apollo/react-hooks';
import { ACCEPT_FRIENDREQUEST, FRIENDREQUEST, ME } from '../../queries';
import { errorHandler, notificationHandler } from '../../utils';

import { ListItemText, ListItemAvatar, Avatar, ListItem } from '@material-ui/core';

export const FriendRequestListItem = ({ userId, request }: any) => {
    const { sender, id } = request;
    const { firstName, lastName } = sender[0];

    const [acceptFriendRequestMutation] = useMutation(ACCEPT_FRIENDREQUEST, {
        onError: errorHandler,
        refetchQueries: [{ query: ME }, { query: FRIENDREQUEST, variables: { id: userId.id } }],
    });

    const acceptFriendRequest = async () => {
        const result = await acceptFriendRequestMutation({
            variables: {
                id,
            },
        });

        if (result) {
            notificationHandler({
                message: `Friend request accepted for ${firstName} ${lastName}`,
                variant: 'success',
            });
        }
    };

    return (
        <ListItem button alignItems="flex-start" key={id} onClick={acceptFriendRequest}>
            <ListItemAvatar>
                <Avatar
                    alt={firstName}
                    src="https://cdn1.thr.com/sites/default/files/imagecache/scale_crop_768_433/2019/03/avatar-publicity_still-h_2019.jpg"
                />
            </ListItemAvatar>
            <ListItemText primary={`${firstName} ${lastName}`} />
        </ListItem>
    );
};
