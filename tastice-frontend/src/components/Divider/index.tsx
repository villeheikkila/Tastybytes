import { createStyles, makeStyles, Theme } from '@material-ui/core';
import Paper from '@material-ui/core/Paper';
import Typography from '@material-ui/core/Typography';
import React from 'react';

const useStyles = makeStyles((theme: Theme) =>
    createStyles({
        paper: {
            maxWidth: 700,
            padding: theme.spacing(1, 0),
            margin: `${theme.spacing(1)}px auto`,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
        },
        textField: {
            marginTop: 10,
        },
    }),
);

interface DividerProps {
    text: string;
}

export const Divider = ({ text }: DividerProps): JSX.Element => {
    const classes = useStyles();

    return (
        <Paper className={classes.paper}>
            <Typography variant="h4" component="h3" className={classes.textField}>
                {text}
            </Typography>
        </Paper>
    );
};
