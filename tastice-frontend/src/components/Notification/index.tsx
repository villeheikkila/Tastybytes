import { useQuery } from '@apollo/react-hooks';
import { Snackbar } from '@material-ui/core';
import React, { SyntheticEvent, useEffect, useState } from 'react';
import { client } from '../../index';
import { GET_NOTIFICATION } from '../../graphql';
import { NotificationContentWrapper } from './NotificationContentWrapper';

export const Notifications = (): JSX.Element | null => {
    const [open, setOpen] = useState(true);
    const notification = useQuery(GET_NOTIFICATION);

    useEffect((): void => {
        if (notification.data.notification) setOpen(true);
    }, [notification]);

    if (notification.data.variant === undefined || notification.data.notification === '') {
        return null;
    }

    const handleCloseNotification = (event?: SyntheticEvent, reason?: string): void => {
        if (reason === 'clickaway') {
            return;
        }

        setOpen(false);

        client.writeData({
            data: {
                notification: '',
                variant: 'success',
            },
        });
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
                variant={notification.data.variant as any}
                message={notification.data.notification}
            />
        </Snackbar>
    );
};
