import { useMutation } from '@apollo/react-hooks';
import { createStyles, makeStyles, Theme } from '@material-ui/core';
import React, { useCallback, useEffect, useState } from 'react';
import { useDropzone } from 'react-dropzone';
import { SmartAvatar } from '../../components/SmartAvatar';
import { ME, UPDATE_AVATAR } from '../../graphql';
import { uploadCloudinary } from '../../services/cloudinary';
import { errorHandler } from '../../utils';

const useStyles = makeStyles((theme: Theme) =>
    createStyles({
        paper: {
            marginTop: 30,
            maxWidth: 700,
            padding: theme.spacing(3, 2),
            margin: `${theme.spacing(1)}px auto`,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            alignContent: 'center',
        },
        avatar: (props: any) => ({
            marginLeft: 30,
            marginRight: 30,
            marginTop: 20,
            marginBottom: 15,
            width: 200,
            backgroundColor: props.avatarColor,
            height: 200,
        }),
        container: {
            display: 'flex',
            flexWrap: 'wrap',
            flexDirection: 'column',
            alignItems: 'center',
            alignContent: 'center',
            justifyContent: 'center',
        },
        title: {
            marginTop: 10,
        },
        button: {
            marginTop: 15,
            width: '30%',
        },
        avatarInitials: {
            margin: 10,
            color: '#fff',
        },
        imageAvatar: {
            marginTop: 20,
        },
    }),
);

export const AccountAvatar = ({ user }: any): JSX.Element | null => {
    const classes = useStyles({ avatarColor: user.avatarColor });
    const [newAvatarId, setNewAvatarId] = useState('');

    const [updateAvatar] = useMutation(UPDATE_AVATAR, {
        onError: errorHandler,
        refetchQueries: [{ query: ME }],
    });

    const onDrop = useCallback(async acceptedFiles => {
        const publicId = await uploadCloudinary(acceptedFiles[0]);
        setNewAvatarId(publicId);
    }, []);

    const { getRootProps, getInputProps } = useDropzone({ onDrop });

    const handleUpdateAvatar = async (): Promise<void> => {
        await updateAvatar({
            variables: {
                id: user.id,
                avatarId: newAvatarId,
            },
        });
    };

    useEffect(() => {
        if (newAvatarId) {
            handleUpdateAvatar();
        }
    }, [newAvatarId]);

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
