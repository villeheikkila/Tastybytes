import { useMutation } from '@apollo/react-hooks';
import { IconButton, ListItem, ListItemAvatar, ListItemText } from '@material-ui/core';
import DeleteIcon from '@material-ui/icons/Delete';
import React, { useState } from 'react';
import { DELETE_FRIEND, ME } from '../../graphql';
import { errorHandler, notificationHandler } from '../../utils';
import { ConfirmationDialog } from '../ConfirmationDialog';
import { SmartAvatar } from '../SmartAvatar';

interface FriendListItemProps {
    userId: string;
    user: User;
}

export const FriendListItem = ({
    userId,
    user: { firstName, lastName, avatarId, id },
}: FriendListItemProps): JSX.Element => {
    const [visible, setVisible] = useState(false);

    const [createFriendRequest] = useMutation(DELETE_FRIEND, {
        onError: errorHandler,
        refetchQueries: [{ query: ME }],
    });

    const handleDeleteFriend = async (): Promise<void> => {
        setVisible(false);
        const result = await createFriendRequest({
            variables: {
                id: userId,
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
                    <SmartAvatar firstName={firstName} lastName={lastName} id={id} avatarId={avatarId} />
                </ListItemAvatar>
                <ListItemText primary={`${firstName} ${lastName}`} />
                <IconButton aria-label="Delete" onClick={(): void => setVisible(true)}>
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
