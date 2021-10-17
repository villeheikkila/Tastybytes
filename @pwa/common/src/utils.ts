import { Nullable } from "./types";

export const getDisplayName = ({
  firstName,
  lastName,
  username,
}: {firstName: Nullable<string>, lastName: Nullable<string>, username: string}) =>
  firstName && lastName ? `${firstName} ${lastName}` : username;
