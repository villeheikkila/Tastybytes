import { Avatar } from '@material-ui/core';
import { Image } from 'cloudinary-react';
import React from 'react';
import { Link } from 'react-router-dom';

interface SmartAvatarProps {
    firstName: string;
    lastName: string;
    id: string;
    avatarId: string;
}
export const SmartAvatar = ({ firstName, lastName, id, avatarId }: SmartAvatarProps): JSX.Element => {
    return (
        <>
            <Avatar alt={firstName} component={Link} to={`/user/${id}`}>
                {avatarId ? (
                    <Image
                        cloudName={process.env.REACT_APP_CLOUDINARY_CLOUD_NAME}
                        publicId={avatarId}
                        width="300"
                        crop="scale"
                    />
                ) : (
                    <Avatar>
                        {firstName.charAt(0)}
                        {lastName.charAt(0)}
                    </Avatar>
                )}
            </Avatar>
        </>
    );
};
