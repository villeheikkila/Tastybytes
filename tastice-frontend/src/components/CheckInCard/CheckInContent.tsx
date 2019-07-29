import React from 'react';
import Rating from 'material-ui-rating';

import { Typography, CardContent } from '@material-ui/core';

interface CheckInContentProps {
    rating: number;
    comment: string;
}

export const CheckInContent = ({ rating, comment }: CheckInContentProps): JSX.Element => {
    return (
        <CardContent>
            <Typography variant="h6" color="textSecondary" component="p">
                {comment && <>Comment: {comment}</>}
            </Typography>
            <Rating value={rating} max={5} />
        </CardContent>
    );
};
