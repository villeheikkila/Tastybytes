import { User } from "@app/graphql";

export const getDisplayName = ({
  firstName,
  lastName,
  username,
}: Pick<User, "firstName" | "lastName" | "username">) =>
  firstName && lastName ? `${firstName} ${lastName}` : username;
