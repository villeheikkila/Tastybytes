import { Avatar, createStyles, makeStyles, Typography } from '@material-ui/core';
import { Image } from 'cloudinary-react';
import React from 'react';
import { Link } from 'react-router-dom';
import { CLOUDINARY_CLOUD_NAME } from '../../index';

interface SmartAvatarProps {
    firstName: string;
    lastName: string;
    id: string;
    avatarId: string;
    avatarColor?: string;
    size?: number;
}

const useStyles = makeStyles(
    createStyles({
        avatar: (props: any) => ({
            margin: 5,
            width: props.size,
            height: props.size,
            backgroundColor: props.avatarColor,
            textDecoration: 'none',
            color: 'white',
        }),
        text: (props: any) => ({
            fontSize: props.size / 3,
            fontWeight: 800,
        }),
    }),
);

export const SmartAvatar = ({
    firstName,
    lastName,
    id,
    avatarId,
    avatarColor = '#f2b50c',
    size = 50,
}: SmartAvatarProps): JSX.Element => {
    const classes = useStyles({ avatarColor, size });

    return (
        <Avatar alt={firstName} component={Link} to={`/user/${id}`} className={classes.avatar}>
            {avatarId ? (
                <Image cloudName={CLOUDINARY_CLOUD_NAME} publicId={avatarId} width={size} crop="thumb"></Image>
            ) : (
                <Typography variant="h6" className={classes.text}>
                    {firstName.charAt(0).toUpperCase()}
                    {lastName.charAt(0).toUpperCase()}
                </Typography>
            )}
        </Avatar>
    );
};
