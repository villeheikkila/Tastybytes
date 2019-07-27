import React from 'react';
import { useMutation } from '@apollo/react-hooks';
import { DELETE_FRIEND } from '../../queries';
import { errorHandler, notificationHandler } from '../../utils';

import { ListItemText, Typography, ListItemAvatar, Avatar, ListItem } from '@material-ui/core';

export const Friends: React.FC<any> = ({ userId, user }) => {
    console.log('userId: ', userId);
    const { firstName, lastName, id } = user;
    console.log('id: ', id);
    const [createFriendRequest] = useMutation(DELETE_FRIEND, {
        onError: errorHandler,
    });

    const deleteFriend = async () => {
        const result = await createFriendRequest({
            variables: {
                id: userId.id,
                friendId: id,
            },
        });

        if (result) {
            console.log('result: ', result);
            notificationHandler({
                message: `Friend request send for ${firstName} ${lastName}`,
                variant: 'success',
            });
        }
    };
    return (
        <ListItem button alignItems="flex-start" key={id} onClick={deleteFriend}>
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
