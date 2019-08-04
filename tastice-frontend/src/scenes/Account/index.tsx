import { useMutation, useQuery } from '@apollo/react-hooks';
import { Avatar, Button, createStyles, Grid, makeStyles, Paper, Theme, Typography } from '@material-ui/core';
import { deepPurple } from '@material-ui/core/colors';
import axios from 'axios';
import { Image } from 'cloudinary-react';
import React, { useCallback, useEffect, useState } from 'react';
import { useDropzone } from 'react-dropzone';
import useReactRouter from 'use-react-router';
import { ConfirmationDialog } from '../../components/ConfirmationDialog';
import { client } from '../../index';
import { DELETE_USER, ME, UPDATE_AVATAR } from '../../queries';
import { errorHandler } from '../../utils';
import { PasswordForm } from './PasswordForm'
import { UserForm } from './UserForm'

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

export const Account = ({ setToken }: Token): JSX.Element | null => {
    const me = useQuery(ME);
    const classes = useStyles();

    const [newAvatarId, setNewAvatarId] = useState('');


    const { history } = useReactRouter();
    const [visible, setVisible] = useState(false);

    const [updateAvatar] = useMutation(UPDATE_AVATAR, {
        onError: errorHandler,
        refetchQueries: [{ query: ME }],
    });

    const [deleteUser] = useMutation(DELETE_USER, {
        onError: errorHandler,
        refetchQueries: [{ query: ME }],
    });

    const uploadPreset = process.env.REACT_APP_CLOUDINARY_UPLOAD_PRESET || 'demo';

    const onDrop = useCallback(async acceptedFiles => {
        const formData = new FormData();
        formData.append('file', acceptedFiles[0]);
        formData.append('upload_preset', uploadPreset);

        const response = await axios.post(
            `https://api.cloudinary.com/v1_1/${process.env.REACT_APP_CLOUDINARY_CLOUD_NAME}/image/upload`,
            formData,
        );

        setNewAvatarId(response.data.public_id);
    }, []);

    const { getRootProps, getInputProps } = useDropzone({ onDrop });

    useEffect(() => {
        if (newAvatarId) {
            const result = async () => {
                await updateAvatar({
                    variables: {
                        id: user.id,
                        avatarId: newAvatarId,
                    },
                });
            }
        }
    }, [newAvatarId])

    if (me.data.me === undefined) {
        return null;
    }

    const user = me.data.me;

    const handleDeleteUser = async (): Promise<void> => {
        setVisible(false);
        await deleteUser({
            variables: { id: user.id },
        });
        await client.clearStore();
        localStorage.clear();
        setToken(null);
        history.push('/');
    };

    return (
        <div>
            <Paper className={classes.paper}>
                <Typography variant="h4" component="h3" className={classes.title}>
                    Edit Profile Settings
                </Typography>
                <div {...getRootProps()}>
                    <input {...getInputProps()} />
                    <Avatar alt="Avatar" className={classes.avatar}>
                        {user.avatarId ? (
                            <Image
                                cloudName={process.env.REACT_APP_CLOUDINARY_CLOUD_NAME}
                                publicId={newAvatarId}
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

                <UserForm user={user} />
                <PasswordForm id={user.id} />

                <Button
                    variant="outlined"
                    color="secondary"
                    className={classes.button}
                    onClick={(): void => setVisible(true)}
                >
                    Delete User
                </Button>

            </Paper>

            <ConfirmationDialog
                visible={visible}
                setVisible={setVisible}
                description={'hei'}
                title={'Warning!'}
                content={'Are you sure you want to remove your account?'}
                onAccept={handleDeleteUser}
                declineButton={'Cancel'}
                acceptButton={'Yes'}
            />
        </div>
    );
};
