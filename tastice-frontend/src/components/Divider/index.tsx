import React from 'react';
import Typography from '@material-ui/core/Typography';
import Paper from '@material-ui/core/Paper';
import { Theme, createStyles, makeStyles } from '@material-ui/core';

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

export const Divider: React.FC<any> = ({ text }) => {
    const classes = useStyles();

    return (
        <Paper className={classes.paper}>
            <Typography variant="h4" component="h3" className={classes.textField}>
                {text}
            </Typography>
        </Paper>
    );
};
