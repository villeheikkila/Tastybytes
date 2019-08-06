import { useMutation, useQuery } from '@apollo/react-hooks';
import { Button, CardContent, createStyles, makeStyles, TextField, Theme, Typography } from '@material-ui/core';
import Rating from 'material-ui-rating';
import React, { useEffect, useState } from 'react';
import { ALL_PRODUCTS, CHECKIN, UPDATE_CHECKIN } from '../../graphql';
import { errorHandler, notificationHandler } from '../../utils';

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
            width: 150,
        },
    }),
);

interface CheckInProps {
    id: string;
    product: string;
    setOpenEdit: React.Dispatch<boolean | undefined>;
    setVisible: React.Dispatch<boolean | undefined>;
}

export const EditCheckIn = ({ id, setOpenEdit, product, setVisible }: CheckInProps): JSX.Element | null => {
    const classes = useStyles();
    const [rating, setRating] = useState();
    const [comment, setComment] = useState();
    const checkinQuery = useQuery(CHECKIN, {
        variables: { id },
    });
    const [updateCheckin] = useMutation(UPDATE_CHECKIN, {
        onError: errorHandler,
        refetchQueries: [{ query: ALL_PRODUCTS }],
    });

    useEffect((): void => {
        if (checkinQuery.data.checkin !== undefined) {
            setComment(checkinQuery.data.checkin[0].comment);
            setRating(checkinQuery.data.checkin[0].rating);
        }
    }, [checkinQuery.data.checkin]);

    const handleEditCheckInEdit = async (): Promise<void> => {
        setOpenEdit(false);
        const result = await updateCheckin({
            variables: {
                id,
                rating,
                comment,
            },
        });
        if (result) {
            notificationHandler({
                message: `Checkin for product '${product}' succesfully updated`,
                variant: 'success',
            });
        }
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
                onChange={(event): void => setComment(event.target.value)}
            />
            <Typography component="p">Rating</Typography>
            <Rating value={rating} max={5} onChange={(i: number): void => setRating(i)} />
            <div>
                <Button variant="contained" color="primary" className={classes.button} onClick={handleEditCheckInEdit}>
                    Edit
                </Button>
                <Button
                    variant="contained"
                    color="secondary"
                    className={classes.button}
                    onClick={() => setVisible(false)}
                >
                    Cancel
                </Button>
            </div>
        </CardContent>
    );
};
