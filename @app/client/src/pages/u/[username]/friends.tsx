import { Card, Layout, SharedLayout } from "@app/components";
import { styled } from "@app/components/src/stitches.config";
import {
  FriendsQuery,
  FriendStatus,
  useAcceptFriendRequestMutation,
  useDeleteFriendMutation,
  useFriendsQuery,
  useSendFriendRequestMutation,
} from "@app/graphql";
import { greenA, redA } from "@radix-ui/colors";
import { NextPage } from "next";
import Link from "next/link";
import { useRouter } from "next/router";
import React, { FC } from "react";
import { z } from "zod";

const parseSlug = z.string();

const FriendsPage: NextPage = () => {
  const router = useRouter();
  const query = useFriendsQuery();
  const username = parseSlug.parse(router.query.username);
  const data = query.data?.publicUsers;

  return (
    <SharedLayout
      title={`${query.data?.currentUser?.username ?? username}`}
      titleHref={`/u/[username]`}
      titleHrefAs={`/u/${username}`}
      query={query}
    >
      {data && <FriendsPageInner data={data} />}
    </SharedLayout>
  );
};

interface FriendsPageInnerProps {
  data: NonNullable<FriendsQuery["publicUsers"]>;
}

const mutationOptions = {
  refetchQueries: ["Friends"],
};

const FriendsPageInner: FC<FriendsPageInnerProps> = ({ data }) => {
  const [sendFriendRequest] = useSendFriendRequestMutation(mutationOptions);
  const [acceptFriendRequest] = useAcceptFriendRequestMutation(mutationOptions);
  const [removeFriend] = useDeleteFriendMutation(mutationOptions);

  const handleFriendStatusChange = async (
    userId: string,
    status: FriendStatus
  ) => {
    try {
      switch (
        status
        // case FriendStatus.Friend:
        //   await removeFriend({ variables: { userId } });
        //   break;
        // case FriendStatus.PendingReceived:
        //   await acceptFriendRequest({ variables: { userId } });
        //   break;
        // case FriendStatus.PendingSent:
        //   await deleteFriendRequest({ variables: { userId } });
        //   break;
        // case FriendStatus.None:
        //   await sendFriendRequest({ variables: { userId } });
        //   break;
      ) {
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
        {data.nodes.map((user) => (
          <Card.Wrapper key={user.id}>
            <Flex>
              <Link href={`/u/${user.username}`}>
                <h2>{user.username}</h2>
              </Link>
              {/* <FriendStatusIcon
                status={user.friendStatus}
                size="2x"
                onClick={() =>
                  handleFriendStatusChange(user.id, user.friendStatus)
                }
              /> */}
            </Flex>
          </Card.Wrapper>
        ))}
      </Card.Container>
    </Layout.Root>
  );
};

// const FriendStatusIcon = ({
//   status,
//   ...props
// }: Omit<FontAwesomeIconProps, "icon" | "color"> & {
//   status: FriendStatus;
// }): JSX.Element => {
//   switch (status) {
//     case FriendStatus.Friend:
//       return <FontAwesomeIcon icon={faMinus} color={redA.redA11} {...props} />;
//     case FriendStatus.PendingReceived:
//       return (
//         <FontAwesomeIcon icon={faCheck} color={greenA.greenA8} {...props} />
//       );
//     case FriendStatus.PendingSent:
//       return (
//         <FontAwesomeIcon icon={faUserClock} color={greenA.greenA8} {...props} />
//       );
//     case FriendStatus.None:
//       return (
//         <FontAwesomeIcon icon={faPlus} color={greenA.greenA8} {...props} />
//       );
//   }
// };
const Flex = styled("div", {
  display: "flex",
  justifyContent: "space-between",
  alignItems: "center",
});

export default FriendsPage;
