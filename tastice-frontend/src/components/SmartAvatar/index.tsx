import { Avatar, createStyles, makeStyles, Typography } from '@material-ui/core';
import { deepOrange } from '@material-ui/core/colors';
import { Image } from 'cloudinary-react';
import React from 'react';
import { Link } from 'react-router-dom';

interface SmartAvatarProps {
    firstName: string;
    lastName: string;
    id: string;
    avatarId: string;
    width?: number;
}

const useStyles = makeStyles(
    createStyles({
        avatar: {
            margin: 5,
            backgroundColor: deepOrange[500],
            textDecoration: 'none',
            color: '#fff',
        },
    }),
);

export const SmartAvatar = ({ firstName, lastName, id, avatarId }: SmartAvatarProps): JSX.Element => {
    const classes = useStyles();

    return (
        <>
            <Avatar alt={firstName} component={Link} to={`/user/${id}`} className={classes.avatar}>
                {avatarId ? (
                    <Image
                        cloudName={process.env.REACT_APP_CLOUDINARY_CLOUD_NAME}
                        publicId={avatarId}
                        width="50"
                        crop="thumb"
                    ></Image>
                ) : (
                    <Typography variant="h6">
                        {firstName.charAt(0).toUpperCase()}
                        {lastName.charAt(0).toUpperCase()}
                    </Typography>
                )}
            </Avatar>
        </>
    );
};
