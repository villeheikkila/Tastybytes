import React from 'react';
import { useMutation } from '@apollo/react-hooks';
import { CREATE_FRIENDREQUEST } from '../../queries';
import { errorHandler, notificationHandler } from '../../utils';

import { ListItemText, Typography, ListItemAvatar, Avatar, ListItem } from '@material-ui/core';

export const FriendListItem: React.FC<any> = ({ me, user }) => {
    const { firstName, lastName, id } = user;
    const [createFriendRequest] = useMutation(CREATE_FRIENDREQUEST, {
        onError: errorHandler,
    });

    const sendFriendRequest = async () => {
        const result = await createFriendRequest({
            variables: {
                senderId: me.id,
                receiverId: id,
                message: 'Moi',
            },
        });

        if (result) {
            notificationHandler({
                message: `Friend request send for ${firstName} ${lastName}`,
                variant: 'success',
            });
        }
    };
    return (
        <ListItem button alignItems="flex-start" key={id} onClick={sendFriendRequest}>
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
