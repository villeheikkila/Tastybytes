import { useMutation } from '@apollo/react-hooks';
import { Avatar, createStyles, makeStyles, Theme, Typography } from '@material-ui/core';
import { deepPurple } from '@material-ui/core/colors';
import { Image } from 'cloudinary-react';
import React, { useCallback, useEffect, useState } from 'react';
import { useDropzone } from 'react-dropzone';
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
        avatar: {
            marginLeft: 30,
            marginRight: 30,
            marginTop: 20,
            marginBottom: 15,
            width: 200,
            backgroundColor: deepPurple[500],
            height: 200,
        },
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
    const classes = useStyles();
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
            <Avatar alt="Avatar" className={classes.avatar}>
                {user.avatarId ? (
                    <Image
                        cloudName={process.env.REACT_APP_CLOUDINARY_CLOUD_NAME}
                        publicId={user.avatarId}
                        width="200"
                        crop="thumb"
                    ></Image>
                ) : (
                    <Typography variant="h3" className={classes.avatarInitials}>
                        {user.firstName.charAt(0).toUpperCase()}
                        {user.lastName.charAt(0).toUpperCase()}
                    </Typography>
                )}
            </Avatar>
        </div>
    );
};
