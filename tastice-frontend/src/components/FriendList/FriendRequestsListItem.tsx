import { useMutation } from '@apollo/react-hooks';
import { IconButton, ListItem, ListItemAvatar, ListItemText, Typography } from '@material-ui/core';
import { Clear, HowToReg } from '@material-ui/icons';
import React from 'react';
import { ACCEPT_FRIENDREQUEST, DELETE_FRIENDREQUEST, FRIENDREQUEST, ME } from '../../graphql';
import { errorHandler, notificationHandler } from '../../utils';
import { SmartAvatar } from '../SmartAvatar';

interface FriendRequestListItemProps {
    userId: string;
    request: FriendRequestObject;
}

export const FriendRequestListItem = ({
    userId,
    request: { sender, receiver, id },
}: FriendRequestListItemProps): JSX.Element => {
    // Display the sender's information for the receiver and the other way around for the sender.
    const userIsTheSender = userId === sender[0].id;
    const show = userIsTheSender ? receiver[0] : sender[0];

    const { firstName, lastName, avatarId, avatarColor } = show;

    const [acceptFriendRequestMutation] = useMutation(ACCEPT_FRIENDREQUEST, {
        onError: errorHandler,
        refetchQueries: [{ query: ME }, { query: FRIENDREQUEST, variables: { id: userId } }],
    });

    const [deleteFriendRequestMutation] = useMutation(DELETE_FRIENDREQUEST, {
        onError: errorHandler,
        refetchQueries: [{ query: ME }, { query: FRIENDREQUEST, variables: { id: userId } }],
    });

    const acceptFriendRequest = async (): Promise<void> => {
        const result = await acceptFriendRequestMutation({
            variables: {
                id,
            },
        });

        if (result) {
            notificationHandler({
                message: `Friend request from ${firstName} ${lastName} accepted`,
                variant: 'success',
            });
        }
    };

    const declineFriendRequest = async (): Promise<void> => {
        const result = await deleteFriendRequestMutation({
            variables: {
                id,
            },
        });

        if (result) {
            if (!userIsTheSender) {
                notificationHandler({
                    message: `Friend request declined for ${firstName} ${lastName}`,
                    variant: 'success',
                });
            } else {
                notificationHandler({
                    message: `Friend request for ${firstName} ${lastName} cancelled`,
                    variant: 'success',
                });
            }
        }
    };

    return (
        <ListItem button alignItems="flex-start" key={id}>
            <ListItemAvatar>
                <SmartAvatar
                    firstName={firstName}
                    lastName={lastName}
                    id={id}
                    avatarId={avatarId}
                    avatarColor={avatarColor}
                />
            </ListItemAvatar>
            <ListItemText primary={`${firstName} ${lastName}`} />

            {!userIsTheSender ? (
                <IconButton aria-label="Accept" color="primary" onClick={acceptFriendRequest}>
                    <HowToReg fontSize="large" />
                </IconButton>
            ) : (
                <Typography> Friend request is pending </Typography>
            )}

            <IconButton aria-label="Clear" color="secondary" onClick={declineFriendRequest}>
                <Clear fontSize="large" />
            </IconButton>
        </ListItem>
    );
};
