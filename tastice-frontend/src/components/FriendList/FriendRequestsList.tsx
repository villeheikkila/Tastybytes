import React from 'react';
import { useMutation } from '@apollo/react-hooks';
import { ACCEPT_FRIENDREQUEST, FRIENDREQUEST } from '../../queries';
import { errorHandler, notificationHandler } from '../../utils';

import { ListItemText, Typography, ListItemAvatar, Avatar, ListItem } from '@material-ui/core';

export const FriendRequestListItem: React.FC<any> = ({ userId, request }) => {
    console.log('userId: ', userId);
    const { sender, id } = request;
    console.log('sender: ', sender);
    const { firstName, lastName } = sender[0];
    const [createFriendRequest] = useMutation(ACCEPT_FRIENDREQUEST, {
        onError: errorHandler,
        refetchQueries: [{ query: FRIENDREQUEST, variables: { id: userId.id } }],
    });

    const acceptFriendRequest = async () => {
        const result = await createFriendRequest({
            variables: {
                id,
            },
        });

        console.log('result: ', result);

        if (result) {
            notificationHandler({
                message: `Friend request accepted for ${''} ${''}`,
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
