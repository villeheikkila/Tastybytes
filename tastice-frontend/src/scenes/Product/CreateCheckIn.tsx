import { useMutation } from '@apollo/react-hooks';
import { Button, createStyles, makeStyles, Paper, TextField, Theme, Typography } from '@material-ui/core';
import Rating from 'material-ui-rating';
import React, { useContext, useState } from 'react';
import { UserContext } from '../../App';
import { ImageUpload } from '../../components/ImageUpload';
import { CREATE_CHECKIN, ME, SEARCH_CHECKINS } from '../../graphql';
import { SEARCH_PRODUCT_CHECKINS } from '../../graphql/checkin';
import { errorHandler, notificationHandler } from '../../utils';

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
    productId: string;
    setSubmitted: any;
}

export const CreateCheckIn = ({ productId, setSubmitted }: CreateCheckInProps): JSX.Element => {
    const classes = useStyles();
    const { id } = useContext(UserContext);
    const [rating, setRating] = useState();
    const [comment, setComment] = useState();
    const [image, setImage] = useState();

    const [createCheckin] = useMutation(CREATE_CHECKIN, {
        onError: errorHandler,
        refetchQueries: [
            { query: ME },
            { query: SEARCH_PRODUCT_CHECKINS, variables: { id: productId, filter: '', first: 5 } },
            { query: SEARCH_CHECKINS, variables: { filter: '', first: 5 } },
        ],
    });

    const handeCheckIn = async (): Promise<void> => {
        const result = await createCheckin({
            variables: {
                authorId: id,
                productId,
                comment,
                image,
                rating,
            },
        });

        if (result) {
            notificationHandler({
                message: `Checkin for '${result.data.createCheckin.product.name}' succesfully added`,
                variant: 'success',
            });
            setSubmitted(result.data.createCheckin);
        }
    };

    return (
        <Paper className={classes.paper}>
            <Typography variant="h5" component="h3">
                How did you like it?
            </Typography>
            <ImageUpload image={image} setImage={setImage} />
            <TextField
                id="outlined-multiline-static"
                label="Comments"
                multiline
                rows="4"
                className={classes.textField}
                margin="normal"
                variant="outlined"
                onChange={({ target }): void => setComment(target.value)}
            />
            <Typography component="p">Rating</Typography>
            <Rating value={rating} max={5} onChange={(i: number): void => setRating(i)} />
            <Button variant="contained" color="primary" className={classes.button} onClick={handeCheckIn}>
                Check-in!
            </Button>
        </Paper>
    );
};
