import React, { SyntheticEvent, useEffect, useState } from "react";
import Snackbar from "@material-ui/core/Snackbar";
import { NotificationContentWrapper } from "./NotificationContentWrapper";
import { INotification } from "../../types";

export const Notifications: React.FC<INotification> = ({
  message,
  variant
}) => {
  const [open, setOpen] = React.useState(true);
  const [notification, setNotification] = useState({
    message: message,
    variant: variant
  });

  useEffect(() => setOpen(true));
  console.log("notification: ", notification);

  if (notification.message === "") {
    return null;
  }

  const handleCloseNotification = (event?: SyntheticEvent, reason?: string) => {
    if (reason === "clickaway") {
      return;
    }

    setOpen(false);
  };

  return (
    <Snackbar
      anchorOrigin={{
        vertical: "top",
        horizontal: "center"
      }}
      open={open}
      autoHideDuration={1000}
      onClose={handleCloseNotification}
    >
      <NotificationContentWrapper
        onClose={handleCloseNotification}
        variant={notification.variant}
        message={notification.message}
      />
    </Snackbar>
  );
};
