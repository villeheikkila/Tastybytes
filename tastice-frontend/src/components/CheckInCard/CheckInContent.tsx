import React from 'react';
import Rating from 'material-ui-rating';

import { Typography, CardContent } from '@material-ui/core';

export interface CheckInContentProps {
    rating: number;
    comment: string;
}

export const CheckInContent: React.FC<CheckInContentProps> = ({ rating, comment }) => {
    return (
        <CardContent>
            <Typography variant="h6" color="textSecondary" component="p">
                {comment && <>Comment: {comment}</>}
            </Typography>
            <Rating value={rating} max={5} />
        </CardContent>
    );
};
