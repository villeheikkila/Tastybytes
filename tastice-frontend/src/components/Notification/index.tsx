import { useQuery } from '@apollo/react-hooks';
import { Snackbar } from '@material-ui/core';
import React, { SyntheticEvent, useEffect, useState } from 'react';
import { NOTIFICATION } from '../../queries';
import { NotificationContentWrapper } from './NotificationContentWrapper';

export const Notifications = (): JSX.Element | null => {
    const [open, setOpen] = useState(false);
    const notification = useQuery(NOTIFICATION);

    useEffect((): void => setOpen(true), [notification]);

    if (notification.data === undefined || notification.data === {} || notification.data.notification === 'clear') {
        return null;
    }

    const handleCloseNotification = (event?: SyntheticEvent, reason?: string): void => {
        if (reason === 'clickaway') {
            return;
        }

        setOpen(false);
    };

    return (
        <Snackbar
            anchorOrigin={{
                vertical: 'top',
                horizontal: 'center',
            }}
            open={open}
            autoHideDuration={1500}
            onClose={handleCloseNotification}
        >
            <NotificationContentWrapper
                onClose={handleCloseNotification}
                variant={'success'}
                message={notification.data.notification}
            />
        </Snackbar>
    );
};
