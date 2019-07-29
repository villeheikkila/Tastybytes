import React, { SyntheticEvent, useEffect, useState } from 'react';
import { NotificationContentWrapper } from './NotificationContentWrapper';
import { NOTIFICATION } from '../../queries';
import { useQuery } from '@apollo/react-hooks';
import { Snackbar } from '@material-ui/core';

export const Notifications = (): JSX.Element | null => {
    const [open, setOpen] = useState(true);
    const notification = useQuery(NOTIFICATION);
    useEffect((): void => setOpen(true), [notification]);

    if (notification.data === undefined || notification.data.notification === 'clear') {
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
