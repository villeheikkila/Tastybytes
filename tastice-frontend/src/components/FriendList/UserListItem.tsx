import React, { useState } from 'react';
import { useMutation } from '@apollo/react-hooks';
import { CREATE_FRIENDREQUEST, ME, FRIENDREQUEST } from '../../queries';
import { errorHandler, notificationHandler } from '../../utils';
import { FriendRequestDialog } from './FriendRequestDialog';
import { ListItemText, ListItemAvatar, Avatar, ListItem } from '@material-ui/core';

export const UserListItem = ({ userId, user }: any) => {
    const { firstName, lastName, id } = user;
    const [message, setMessage] = useState();
    const [visible, setVisible] = useState(false);

    const [createFriendRequest] = useMutation(CREATE_FRIENDREQUEST, {
        onError: errorHandler,
        refetchQueries: [{ query: ME }, { query: FRIENDREQUEST, variables: { id: userId.id } }],
    });

    const sendFriendRequest = async () => {
        setVisible(false);
        const result = await createFriendRequest({
            variables: {
                senderId: userId.id,
                receiverId: id,
                message,
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
        <>
            <ListItem button alignItems="flex-start" key={id} onClick={() => setVisible(true)}>
                <ListItemAvatar>
                    <Avatar
                        alt={firstName}
                        src="https://cdn1.thr.com/sites/default/files/imagecache/scale_crop_768_433/2019/03/avatar-publicity_still-h_2019.jpg"
                    />
                </ListItemAvatar>
                <ListItemText primary={`${firstName} ${lastName}`} />
            </ListItem>
            <FriendRequestDialog
                message={message}
                setMessage={setMessage}
                visible={visible}
                setVisible={setVisible}
                onClick={sendFriendRequest}
            />
        </>
    );
};
