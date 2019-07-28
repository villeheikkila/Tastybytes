import { client } from '../index';

export const notificationHandler = (notification: NotificationContent) => {
    client.writeData({
        data: {
            notification: notification.message,
            variant: notification.variant,
        },
    });
    setTimeout(
        () =>
            client.writeData({
                data: {
                    notification: 'clear',
                    variant: 'success',
                },
            }),
        2500,
    );
};

export const errorHandler = (error: any) => {
    client.writeData({
        data: {
            notification: error.message,
            variant: 'error',
        },
    });
    setTimeout(
        () =>
            client.writeData({
                data: {
                    notification: 'clear',
                    variant: 'success',
                },
            }),
        2500,
    );
};

export const filterChanger = (filter: any) => {
    client.writeData({
        data: {
            filter,
        },
    });
};

export const themeSwitcher = (value: boolean) => {
    localStorage.setItem('theme', `${value}`);
    client.writeData({
        data: {
            theme: value,
        },
    });
};
