import React, { useState } from 'react';
import { useMutation } from '@apollo/react-hooks';
import { DELETE_FRIEND, ME } from '../../queries';
import { errorHandler, notificationHandler } from '../../utils';
import { ConfirmationDialog } from '../ConfirmationDialog';
import DeleteIcon from '@material-ui/icons/Delete';
import { Link } from 'react-router-dom';

import { ListItemText, IconButton, ListItemAvatar, Avatar, ListItem } from '@material-ui/core';

export const FriendListItem = ({ userId, user: { firstName, lastName, id } }: any): JSX.Element => {
    const [visible, setVisible] = useState(false);

    const [createFriendRequest] = useMutation(DELETE_FRIEND, {
        onError: errorHandler,
        refetchQueries: [{ query: ME }],
    });

    const handleDeleteFriend = async (): Promise<void> => {
        setVisible(false);
        const result = await createFriendRequest({
            variables: {
                id: userId.id,
                friendId: id,
            },
        });

        if (result) {
            notificationHandler({
                message: `${firstName} ${lastName} was succesfully removed from your friend list`,
                variant: 'success',
            });
        }
    };

    return (
        <>
            <ListItem button alignItems="flex-start" key={id}>
                <ListItemAvatar>
                    <Avatar
                        alt={firstName}
                        src="https://cdn1.thr.com/sites/default/files/imagecache/scale_crop_768_433/2019/03/avatar-publicity_still-h_2019.jpg"
                        component={Link}
                        to={`/user/${id}`}
                    />
                </ListItemAvatar>
                <ListItemText primary={`${firstName} ${lastName}`} />
                <IconButton aria-label="Delete" onClick={() => setVisible(true)}>
                    <DeleteIcon fontSize="large" />
                </IconButton>
            </ListItem>
            <ConfirmationDialog
                key={firstName}
                visible={visible}
                setVisible={setVisible}
                description={'hei'}
                title={'Warning!'}
                content={`Are you sure you want to remove ${firstName} ${lastName} from your friends?`}
                onAccept={handleDeleteFriend}
                declineButton={'Cancel'}
                acceptButton={'Yes'}
            />
        </>
    );
};
