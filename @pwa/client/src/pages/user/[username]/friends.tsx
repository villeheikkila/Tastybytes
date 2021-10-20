import { faCheck, faMinus, faPlus, faUserClock } from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon, FontAwesomeIconProps } from "@fortawesome/react-fontawesome";
import { Nullable, paths } from "@pwa/common";
import { Card, Layout, SharedLayout } from "@pwa/components";
import { styled } from "@pwa/components";
import {
  CurrentUserFriendsQuery,
  FriendStatus,
  useAcceptFriendRequestMutation,
  useCurrentUserFriendsQuery,
  useDeleteFriendMutation,
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
  const query = useCurrentUserFriendsQuery();
  const username = parseSlug.parse(router.query.username);
  const data = query.data?.currentUserFriends;
  const users = query.data?.publicUsers;

  console.log('data: ', data);

  return (
    <SharedLayout
      title={`${query.data?.currentUser?.username ?? username}`}
      query={query}
    >
      {data && users && <FriendsPageInner data={data} users={users} />}
    </SharedLayout>
  );
};

interface FriendsPageInnerProps {
  data: NonNullable<CurrentUserFriendsQuery["currentUserFriends"]>;
  users: NonNullable<CurrentUserFriendsQuery["publicUsers"]>;
}

const mutationOptions = {
  refetchQueries: ["CurrentUserFriends"],
};

const FriendsPageInner: FC<FriendsPageInnerProps> = ({ data, users }) => {
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
        {data.nodes.map((friend) => (
          <Card.Wrapper key={friend.id}>
            <Flex>
              <Link href={paths.user(friend?.username ?? "")}>
                <h2>{friend.username}</h2>
              </Link>
              <FriendStatusIcon
                status={friend.status}
                size="2x"
                onClick={() =>
                  handleFriendStatusChange(friend.userId, friend.status, true)
                }
              />
            </Flex>
          </Card.Wrapper>
        ))}
        
      </Card.Container>
      <h1>Search Friends</h1>
      <Card.Container>
        {users.nodes.filter(({status}) => !status).map((user) => (
          <Card.Wrapper key={user.id}>
            <Flex>
              <Link href={paths.user(user?.username ?? "")}>
                <h2>{user.username}</h2>
              </Link>
              <FriendStatusIcon
                status={user.status}
                size="2x"
                onClick={() =>
                  handleFriendStatusChange(user.id, user.status, true)
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
