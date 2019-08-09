import { useQuery } from '@apollo/react-hooks';
import { Snackbar } from '@material-ui/core';
import React, { SyntheticEvent, useEffect, useState } from 'react';
import { GET_NOTIFICATION } from '../../graphql';
import { client } from '../../index';
import { NotificationContentWrapper } from './NotificationContentWrapper';

export const Notifications = (): JSX.Element | null => {
    const [open, setOpen] = useState(true);
    const { data } = useQuery(GET_NOTIFICATION);
    const { notification, variant } = data;

    useEffect((): void => {
        if (notification) setOpen(true);
    }, [notification]);

    if (notification === undefined || notification === '' || variant === undefined) {
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
                variant={variant as any}
                message={notification}
            />
        </Snackbar>
    );
};
