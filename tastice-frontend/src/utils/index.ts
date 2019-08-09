import { client } from '../index';

interface NotificationContent {
    message: string;
    variant: any;
}

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

export const parseToken = (data: any): string | undefined => {
    try {
        const result = JSON.parse(data);
        return result.token;
    } catch {
        return undefined;
    }
};
