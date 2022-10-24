import { useApolloClient, useMutation } from '@apollo/react-hooks';
import { ListItem, ListItemAvatar, ListItemText } from '@material-ui/core';
import React, { useState } from 'react';
import { CREATE_FRIENDREQUEST, FRIENDREQUEST, ME } from '../../graphql';
import { SmartAvatar } from '../SmartAvatar';
import { FriendRequestDialog } from './FriendRequestDialog';
interface UserListItemProps {
    userId: string;
    user: User;
}

export const UserListItem = ({
    userId,
    user: { firstName, lastName, avatarId, id, avatarColor },
}: UserListItemProps): JSX.Element => {
    const [message, setMessage] = useState('');
    const [visible, setVisible] = useState(false);

    const client = useApolloClient();
    const [createFriendRequest] = useMutation(CREATE_FRIENDREQUEST, {
        onError: error => {
            client.writeData({
                data: {
                    notification: error.message,
                    variant: 'error',
                },
            });
        },
        refetchQueries: [{ query: ME }, { query: FRIENDREQUEST, variables: { id: userId } }],
    });

    const sendFriendRequest = async (): Promise<void> => {
        setVisible(false);
        const result = await createFriendRequest({
            variables: {
                senderId: userId,
                receiverId: id,
                message,
            },
        });

        if (result) {
            client.writeData({
                data: {
                    notification: `Friend request sent for ${firstName} ${lastName}`,
                    variant: 'success',
                },
            });
        }
    };

    return (
        <>
            <ListItem button alignItems="flex-start" key={id} onClick={(): void => setVisible(true)}>
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
