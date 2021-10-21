import { faCheck, faMinus, faPlus, faUserClock } from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon, FontAwesomeIconProps } from "@fortawesome/react-fontawesome";
import { Nullable, paths } from "@pwa/common";
import { Card, Layout, SharedLayout } from "@pwa/components";
import { styled } from "@pwa/components";
import {
  CurrentUserFriendsQuery,
  FriendsByUsernameQuery,
  FriendStatus,
  useAcceptFriendRequestMutation,
  useCurrentUserFriendsQuery,
  useDeleteFriendMutation,
  useFriendsByUsernameQuery,
  useSendFriendRequestMutation,
} from "@pwa/graphql";
import { NextPage } from "next";
import Link from "next/link";
import { useRouter } from "next/router";
import React, { FC } from "react";
import { z } from "zod";

const parseSlug = z.string();

const FriendsPage: NextPage = () => {
  const router = useRouter();
  const username = parseSlug.parse(router.query.username);
  
  const query = useFriendsByUsernameQuery({variables: {username}});
  const data = query.data?.userByUsername;

  return (
    <SharedLayout
      title={`${query.data?.currentUser?.username ?? username}`}
      query={query}
    >
      {data && <FriendsPageInner data={data}  />}
    </SharedLayout>
  );
};

interface FriendsPageInnerProps {
  data: NonNullable<FriendsByUsernameQuery["userByUsername"]>;
}

const mutationOptions = {
  refetchQueries: ["CurrentUserFriends"],
};

const FriendsPageInner: FC<FriendsPageInnerProps> = ({ data }) => {
  const [sendFriendRequest] = useSendFriendRequestMutation(mutationOptions);
  const [acceptFriendRequest] = useAcceptFriendRequestMutation(mutationOptions);
  const [removeFriend] = useDeleteFriendMutation(mutationOptions);

  const handleFriendStatusChange = async (
    userId: string,
    status: Nullable<FriendStatus>,
    isSender: boolean
  ) => {
    try {
      switch (status) {
        case FriendStatus.Accepted:
          await removeFriend({ variables: { userId } });
          break;
        case FriendStatus.Pending: {
          if (isSender) {
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
      console.error(error);
    }
    console.log("userId: ", userId);
  };

  return (
    <Layout.Root>
      <Layout.Header>
        <h1>Friends</h1>
      </Layout.Header>
      <Card.Container>
        {data.friends.nodes.map((friend) => (
          <Card.Wrapper key={friend.id}>
            <Flex>
              <Link href={paths.user(friend?.username ?? "")}>
                <h2>{friend.username}</h2>
              </Link>
              <FriendStatusIcon
                status={friend.currentUserStatus}
                size="2x"
                onClick={() =>
                  handleFriendStatusChange(friend.id, friend.currentUserStatus, true)
                }
              />
            </Flex>
          </Card.Wrapper>
        ))}
        
      </Card.Container>
    </Layout.Root>
  );
};

const FriendStatusIcon = ({
  status,
  ...props
}: Omit<FontAwesomeIconProps, "icon" | "color"> & {
  status: Nullable<FriendStatus>;
}): JSX.Element => {
  switch (status) {
    case FriendStatus.Accepted:
      return <FontAwesomeIcon icon={faMinus} color="red" {...props} />;
    case FriendStatus.Pending:
      return (
        <FontAwesomeIcon icon={faUserClock} color="green" {...props} />
      );
   default:
      return (
        <FontAwesomeIcon icon={faPlus} color="green" {...props} />
      );
  }
};
const Flex = styled("div", {
  display: "flex",
  justifyContent: "space-between",
  alignItems: "center",
});

export default FriendsPage;
