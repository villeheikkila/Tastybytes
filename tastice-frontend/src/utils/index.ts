import { client } from '../index';

export const notificationHandler = (notification: NotificationContent): void => {
    client.writeData({
        data: {
            notification: notification.message,
            variant: notification.variant,
        },
    });
    setTimeout(
        (): void =>
            client.writeData({
                data: {
                    notification: 'clear',
                    variant: 'success',
                },
            }),
        2500,
    );
};

export const errorHandler = (error: any): void => {
    client.writeData({
        data: {
            notification: error.message,
            variant: 'error',
        },
    });
    setTimeout(
        (): void =>
            client.writeData({
                data: {
                    notification: 'clear',
                    variant: 'success',
                },
            }),
        2500,
    );
};

export const filterChanger = (filter: string): void => {
    client.writeData({
        data: {
            filter,
        },
    });
};

export const themeSwitcher = (value: boolean): void => {
    localStorage.setItem('theme', `${value}`);
    client.writeData({
        data: {
            theme: value,
        },
    });
};
