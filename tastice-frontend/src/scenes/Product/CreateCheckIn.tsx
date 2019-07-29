import React, { useState } from 'react';
import { useMutation } from '@apollo/react-hooks';
import Rating from 'material-ui-rating';
import { notificationHandler, errorHandler } from '../../utils';
import { CREATE_CHECKIN, ALL_CHECKINS, ME, PRODUCT } from '../../queries';

import { makeStyles, createStyles, Theme, Paper, Button, TextField, Typography } from '@material-ui/core';

const useStyles = makeStyles((theme: Theme) =>
    createStyles({
        paper: {
            padding: theme.spacing(3, 2),
            maxWidth: 700,
            margin: `${theme.spacing(1)}px auto`,
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

interface CreateCheckInProps {
    authorId: string;
    productId: string;
}

export const CreateCheckIn = ({ authorId, productId }: CreateCheckInProps): JSX.Element => {
    const classes = useStyles();
    const [rating, setRating] = useState();
    const [comment, setComment] = useState();
    const [createCheckin] = useMutation(CREATE_CHECKIN, {
        onError: errorHandler,
        refetchQueries: [{ query: ALL_CHECKINS }, { query: ME }, { query: PRODUCT, variables: { id: productId } }],
    });

    const handeCheckIn = async (): Promise<void> => {
        const result = await createCheckin({
            variables: {
                authorId: authorId,
                productId: productId,
                comment,
                rating,
            },
        });

        if (result) {
            notificationHandler({
                message: `Checkin for '${result.data.createCheckin.product.name}' succesfully added`,
                variant: 'success',
            });
        }
    };

    return (
        <div>
            <Paper className={classes.paper}>
                <Typography variant="h5" component="h3">
                    How did you like it?
                </Typography>
                <TextField
                    id="outlined-multiline-static"
                    label="Comments"
                    multiline
                    rows="4"
                    className={classes.textField}
                    margin="normal"
                    variant="outlined"
                    onChange={(event: any): void => setComment(event.target.value)}
                />
                <Typography component="p">Rating</Typography>
                <Rating value={rating} max={5} onChange={(i: number): void => setRating(i)} />
                <Button variant="contained" color="primary" className={classes.button} onClick={handeCheckIn}>
                    Check-in!
                </Button>
            </Paper>
        </div>
    );
};
