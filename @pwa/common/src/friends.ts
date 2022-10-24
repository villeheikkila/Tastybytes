import { ApolloError } from "@apollo/client";
import {
  FriendStatus, useAcceptFriendRequestMutation,
  useDeleteFriendMutation, useSendFriendRequestMutation
} from "@pwa/graphql";
import { useState } from "react";
import { Nullable } from "./types";


export const useFriendStatus = (options: { refetchQueries: string[] }) => {
  const [error, setError] = useState<Error | ApolloError | null>(null);
  const [sendFriendRequest] = useSendFriendRequestMutation(options);
  const [acceptFriendRequest] = useAcceptFriendRequestMutation(options);
  const [removeFriend] = useDeleteFriendMutation(options);

  const changeFriendStatus = async (
    userId: string,
    current: Nullable<{
      status: Nullable<FriendStatus>,
      isSender: Nullable<boolean>
    }>
  ) => {
    if (!current) {
      await sendFriendRequest({ variables: { userId } });
    } else {
    try {
      switch (current.status) {
        case FriendStatus.Accepted:
          await removeFriend({ variables: { userId } });
          break;
        case FriendStatus.Pending: {
          if (current.isSender) {
            await removeFriend({ variables: { userId } });
          } else {
            await acceptFriendRequest({ variables: { userId } });
          }
          break;
        }
        default:
          await sendFriendRequest({ variables: { userId } });
          break;
      }
    } catch (error) {
      setError(error);
    }
  }
  };
  return { changeFriendStatus, error };
};
