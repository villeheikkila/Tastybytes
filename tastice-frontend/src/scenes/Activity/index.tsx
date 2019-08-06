import { useQuery } from '@apollo/react-hooks';
import { Grid, makeStyles, Typography } from '@material-ui/core';
import React from 'react';
import { CheckInCard } from '../../components/CheckInCard';
import { FILTER, SEARCH_CHECKINS } from '../../graphql';
import { errorHandler } from '../../utils';

const useStyles = makeStyles(theme => ({
    root: {
        flexGrow: 1,
        overflow: 'hidden',
        maxWidth: 700,
        margin: `${theme.spacing(1)}px auto`,
        alignContent: 'center',
        position: 'relative',
    },
}));

export const Activity = (): JSX.Element | null => {
    const classes = useStyles();
    const filter = useQuery(FILTER);

    const checkins = useQuery(SEARCH_CHECKINS, {
        variables: { filter: filter.data.filter },
        onError: errorHandler,
    });

    if (checkins === undefined || checkins.data.searchCheckins === undefined) {
        return null;
    }

    const noResults = checkins.data.searchCheckins.length === 0;

    return (
        <div className={classes.root}>
            {noResults && <Typography variant="h5">No checkins found</Typography>}
            <Grid container justify="center" spacing={10}>
                <Grid item xs={12}>
                    {checkins.data.searchCheckins.map(
                        (checkin: CheckInObject): JSX.Element => (
                            <CheckInCard key={checkin.id} showProduct={true} checkin={checkin} />
                        ),
                    )}
                </Grid>
            </Grid>
        </div>
    );
};
