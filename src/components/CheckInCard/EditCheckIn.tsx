import { useMutation, useQuery } from '@apollo/react-hooks';
import { Button, CardContent, createStyles, makeStyles, TextField, Theme, Typography } from '@material-ui/core';
import Rating from 'material-ui-rating';
import React, { useEffect, useState } from 'react';
import { ALL_PRODUCTS, CHECKIN, UPDATE_CHECKIN } from '../../graphql';

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
    const classes = useStyles({});
    const [rating, setRating] = useState();
    const [comment, setComment] = useState();

    const { data, client } = useQuery(CHECKIN, {
        variables: { id },
    });
    const [updateCheckin] = useMutation(UPDATE_CHECKIN, {
        onError: error => {
            client.writeData({
                data: {
                    notification: error.message,
                    variant: 'error',
                },
            });
        },
        refetchQueries: [{ query: ALL_PRODUCTS }],
    });

    useEffect((): void => {
        if (data && data.checkin) {
            setComment(data.checkin[0].comment);
            setRating(data.checkin[0].rating);
        }
    }, [data]);

    if (!data || !data.checkin) {
        return <div>Loading...</div>;
    }

    const { checkin } = data;

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
            client.writeData({
                data: {
                    notification: `Checkin for product '${product}' succesfully updated`,
                    variant: 'success',
                },
            });
        }
    };

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
                defaultValue={checkin[0].comment}
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
