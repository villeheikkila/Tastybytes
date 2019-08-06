import { useQuery } from '@apollo/react-hooks';
import { Grid, makeStyles, Typography } from '@material-ui/core';
import React, { Fragment } from 'react';
import { Waypoint } from 'react-waypoint';
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

    const { data, fetchMore } = useQuery(SEARCH_CHECKINS, {
        variables: { filter: filter.data.filter, first: 5 },
        onError: errorHandler,
    });

    if (data === undefined || data.searchCheckins === undefined) {
        return null;
    }

    const loadMore = (): void => {
        fetchMore({
            variables: {
                skip: data.searchCheckins.length,
            },
            updateQuery: (prev: any, { fetchMoreResult }) => {
                if (!fetchMoreResult) return prev;
                return Object.assign({}, prev, {
                    searchCheckins: [...prev.searchCheckins, ...fetchMoreResult.searchCheckins],
                });
            },
        });
    };

    const noResults = data.searchCheckins.length === 0;

    return (
        <div className={classes.root}>
            {noResults && <Typography variant="h5">No checkins found</Typography>}
            <Grid container justify="center" spacing={10}>
                <Grid item xs={12}>
                    {data.searchCheckins.map(
                        (checkin: CheckInObject, index: number): JSX.Element => (
                            <Fragment key={checkin.id.toUpperCase()}>
                                {data.searchCheckins.length - index <= 1 && <Waypoint onEnter={loadMore} />}
                                <CheckInCard key={checkin.id} showProduct={true} checkin={checkin} />
                            </Fragment>
                        ),
                    )}
                </Grid>
            </Grid>
        </div>
    );
};
