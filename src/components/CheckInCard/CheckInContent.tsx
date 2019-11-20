import { CardContent, Typography } from '@material-ui/core';
import { Image } from 'cloudinary-react';
import Rating from 'material-ui-rating';
import React from 'react';
import { CLOUDINARY_CLOUD_NAME } from '../..';

interface CheckInContentProps {
    rating: number;
    comment: string;
    image: string;
    readOnly?: boolean;
}

export const CheckInContent = ({ rating, comment, image, readOnly = false }: CheckInContentProps): JSX.Element => {
    return (
        <CardContent>
            <Image cloudName={CLOUDINARY_CLOUD_NAME} publicId={image} width="200" crop="thumb"></Image>

            <Typography variant="h6" color="textSecondary" component="p">
                {comment && <>Comment: {comment}</>}
            </Typography>
            <Rating value={rating} max={5} readOnly={readOnly} />
        </CardContent>
    );
};
