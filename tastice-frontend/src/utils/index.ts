import { client } from "../index";
import { INotification } from "../types";

export const notificationHandler = (notification: INotification) => {
  client.writeData({
    data: {
      notification: notification.message,
      variant: notification.variant
    }
  });
  setTimeout(
    () =>
      client.writeData({
        data: {
          notification: "clear",
          variant: "success"
        }
      }),
    2500
  );
};

export const errorHandler = (error: any) => {
  client.writeData({
    data: {
      notification: error.message,
      variant: "error"
    }
  });
};
