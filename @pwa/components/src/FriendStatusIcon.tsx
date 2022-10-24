import {
  faCheckCircle,
  faMinus,
  faPlus,
  faUserClock
} from "@fortawesome/free-solid-svg-icons";
import {
  FontAwesomeIcon,
  FontAwesomeIconProps
} from "@fortawesome/react-fontawesome";
import { Nullable } from "@pwa/common";
import {
  FriendStatus
} from "@pwa/graphql";
import React from "react";

interface ExtendedFriendStatus {
  status: Nullable<FriendStatus>;
  isSender: Nullable<boolean>;
}

export const FriendStatusIcon = ({
  friendStatus,
  ...props
}: Omit<FontAwesomeIconProps, "icon" | "color"> & {
  friendStatus: Nullable<ExtendedFriendStatus>;
}): JSX.Element => {
  switch (friendStatus?.status) {
    case FriendStatus.Accepted:
      return <FontAwesomeIcon icon={faMinus} color="red" {...props} />;
    case FriendStatus.Pending:
      if (friendStatus?.isSender) {
        return <FontAwesomeIcon icon={faUserClock} color="green" {...props} />;
      } else {
        return <FontAwesomeIcon icon={faCheckCircle} color="green" {...props} />;
      }
    default:
      return <FontAwesomeIcon icon={faPlus} color="green" {...props} />;
  }
};
