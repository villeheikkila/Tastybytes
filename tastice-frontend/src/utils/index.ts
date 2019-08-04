import { client } from '../index';

export const notificationHandler = (notification: NotificationContent): void => {
    client.writeData({
        data: {
            notification: notification.message,
            variant: notification.variant,
        },
    });
};

export const errorHandler = (error: any): void => {
    client.writeData({
        data: {
            notification: error.message,
            variant: 'error',
        },
    });
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

export const randomColorGenerator = (): string => {
    return '#' + (0x1000000 + Math.random() * 0xffffff).toString(16).substr(1, 6);
};
