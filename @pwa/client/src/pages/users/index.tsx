import {
  faCheck,
  faMinus,
  faPlus,
  faUserClock,
} from "@fortawesome/free-solid-svg-icons";
import {
  FontAwesomeIcon,
  FontAwesomeIconProps,
} from "@fortawesome/react-fontawesome";
import { Nullable, paths } from "@pwa/common";
import { Card, Input, Layout, SharedLayout } from "@pwa/components";
import { styled } from "@pwa/components";
import {
  FriendStatus,
  SearchUsersQuery,
  useAcceptFriendRequestMutation,
  useDeleteFriendMutation,
  useSearchUsersLazyQuery,
  useSendFriendRequestMutation,
  useSharedQuery,
} from "@pwa/graphql";
import { NextPage } from "next";
import Link from "next/link";
import React, { FC } from "react";
import { useForm } from "react-hook-form";

interface SearchFormInput {
  search: string;
}

const FriendsPage: NextPage = () => {
  const shared = useSharedQuery();
  const [getUsers, { data }] = useSearchUsersLazyQuery();

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<SearchFormInput>();

  const onSubmit = async ({ search }: SearchFormInput) => {
    await getUsers({ variables: { search } })
  };

  return (
    <SharedLayout
      title={`${shared.data?.currentUser?.username}`}
      query={shared}
    >
      <form onSubmit={handleSubmit(onSubmit)}>
        <Input
          id="search"
          autoComplete="search"
          placeholder="search"
          aria-invalid={errors.search ? "true" : "false"}
          {...register("search", {
            required: true,
            min: 2,
          })}
        />
          <button type="submit">Search</button>
      </form>
      {data?.searchUsers && <FriendsPageInner users={data.searchUsers} />}
    </SharedLayout>
  );
};

interface FriendsPageInnerProps {
  users: NonNullable<SearchUsersQuery["searchUsers"]>;
}

const mutationOptions = {
  refetchQueries: ["UserSearch"],
};

const FriendsPageInner: FC<FriendsPageInnerProps> = ({ users }) => {
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
        <h1>Users</h1>
      </Layout.Header>
      <Card.Container>
        {users.nodes.map((friend) => (
          <Card.Wrapper key={friend.id}>
            <Flex>
              <Link href={paths.user(friend?.username ?? "")}>
                <h2>{friend.username}</h2>
              </Link>
              {/* <FriendStatusIcon
                status={friend.status}
                size="2x"
                onClick={() =>
                  handleFriendStatusChange(friend.id, friend.status, true)
                }
              /> */}
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
      return <FontAwesomeIcon icon={faUserClock} color="green" {...props} />;
    default:
      return <FontAwesomeIcon icon={faPlus} color="green" {...props} />;
  }
};
const Flex = styled("div", {
  display: "flex",
  justifyContent: "space-between",
  alignItems: "center",
});

export default FriendsPage;
