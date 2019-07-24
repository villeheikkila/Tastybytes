import React, { useState, useEffect } from 'react';
import { useMutation, useQuery } from '@apollo/react-hooks';
import Rating from 'material-ui-rating';
import { notificationHandler, errorHandler } from '../../utils';
import { CHECKIN } from '../../queries';

import { makeStyles, createStyles, Theme, Button, TextField, Typography, CardContent } from '@material-ui/core';

const useStyles = makeStyles((theme: Theme) =>
    createStyles({
        card: {
            padding: theme.spacing(3, 2),
            maxWidth: 700,
            display: 'flex',
            flexDirection: 'column',
        },
        textField: {
            marginLeft: theme.spacing(1),
            marginRight: theme.spacing(1),
        },
        button: {
            margin: theme.spacing(1),
        },
    }),
);

export interface CheckInProps {
    id: string;
    setOpenEdit: any;
}

export const EditCheckIn: React.FC<CheckInProps> = ({ id, setOpenEdit }) => {
    const classes = useStyles();
    const [rating, setRating] = useState();
    const [comment, setComment] = useState();
    const checkinQuery = useQuery(CHECKIN, {
        variables: { id },
    });

    useEffect(() => {
        if (checkinQuery.data.checkin !== undefined) {
            setComment(checkinQuery.data.checkin[0].comment);
            setRating(checkinQuery.data.checkin[0].rating);
        }
    }, []);

    const handleEditCheckInEdit = () => {
        setOpenEdit(false);
    };

    if (checkinQuery.data.checkin === undefined) {
        return null;
    }

    return (
        <CardContent className={classes.card}>
            <Typography variant="h5" component="h3">
                Edit Previous Checkin
            </Typography>
            <TextField
                id="outlined-multiline-static"
                label="Comments"
                multiline
                rows="4"
                defaultValue={checkinQuery.data.checkin[0].comment}
                className={classes.textField}
                value={comment}
                margin="normal"
                variant="outlined"
                onChange={(event: any) => setComment(event.target.value)}
            />
            <Typography component="p">Rating</Typography>
            <Rating value={rating} max={5} onChange={(i: any) => setRating(i)} />
            <Button variant="contained" color="primary" className={classes.button} onClick={handleEditCheckInEdit}>
                Check-in!
            </Button>
        </CardContent>
    );
};
