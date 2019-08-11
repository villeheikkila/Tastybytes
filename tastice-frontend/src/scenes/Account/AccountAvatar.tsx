import { useMutation, useApolloClient } from '@apollo/react-hooks';
import React, { useCallback, useEffect, useState } from 'react';
import { useDropzone } from 'react-dropzone';
import { SmartAvatar } from '../../components/SmartAvatar';
import { ME, UPDATE_AVATAR } from '../../graphql';
import { uploadCloudinary } from '../../services/cloudinary';

export const AccountAvatar = ({ user }: any): JSX.Element | null => {
    const [newAvatarId, setNewAvatarId] = useState('');
    const client = useApolloClient();

    const [updateAvatar] = useMutation(UPDATE_AVATAR, {
        onError: error => {
            client.writeData({
                data: {
                    notification: error.message,
                    variant: 'error',
                },
            });
        },
        refetchQueries: [{ query: ME }],
    });

    const onDrop = useCallback(async acceptedFiles => {
        const publicId = await uploadCloudinary(acceptedFiles[0]);
        setNewAvatarId(publicId);
    }, []);

    const { getRootProps, getInputProps } = useDropzone({ onDrop });

    const handleUpdateAvatar = useCallback(async (): Promise<void> => {
        await updateAvatar({
            variables: {
                id: user.id,
                avatarId: newAvatarId,
            },
        });
    }, [newAvatarId, updateAvatar, user.id]);

    useEffect(() => {
        if (newAvatarId) {
            handleUpdateAvatar();
        }
    }, [newAvatarId, handleUpdateAvatar]);

    return (
        <div {...getRootProps()}>
            <input {...getInputProps()} />
            <SmartAvatar
                id={user.id}
                size={200}
                firstName={user.firstName}
                lastName={user.lastName}
                avatarId={user.avatarId}
                avatarColor={user.avatarColor}
                isClickable={false}
            />
        </div>
    );
};
